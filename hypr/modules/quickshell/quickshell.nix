{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.quickshell;
  quickshellPkg = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  qsConfigName = "ii";

  # Use stdenv.mkDerivation with wrapQtAppsHook to properly wrap Qt dependencies
  # symlinkJoin doesn't properly invoke the Qt wrapper hooks
  quickshellWrapped = pkgs.stdenv.mkDerivation {
    name = "quickshell-wrapped";
    meta = with pkgs.lib; {
      description = "Quickshell with bundled Qt deps for home-manager usage";
      license = licenses.gpl3Only;
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.qt6.wrapQtAppsHook
    ];

    buildInputs = with pkgs; [
      quickshellPkg
      kdePackages.qtwayland
      kdePackages.qtpositioning
      kdePackages.qtlocation
      kdePackages.syntax-highlighting
      gsettings-desktop-schemas
      # Qt6 modules needed for QML imports
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qt5compat
      qt6.qtimageformats
      qt6.qtmultimedia
      qt6.qtpositioning
      qt6.qtquicktimeline
      qt6.qtsensors
      qt6.qtsvg
      qt6.qttools
      qt6.qttranslations
      qt6.qtvirtualkeyboard
      qt6.qtwayland
      kdePackages.kirigami
      kdePackages.kdialog
      kdePackages.qt5compat
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      # wrapQtAppsHook will automatically wrap binaries with Qt paths
      cp ${quickshellPkg}/bin/quickshell $out/bin/quickshell || true
      cp ${quickshellPkg}/bin/qs $out/bin/qs || true
      # If cp didn't work (read-only), create wrapper scripts
      if [ ! -x "$out/bin/qs" ]; then
        makeWrapper ${quickshellPkg}/bin/qs $out/bin/qs \
          --prefix XDG_DATA_DIRS : ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}
      fi
      runHook postInstall
    '';
  };
  quickshellConfigSrc = ./config;
  quickshellConfig = pkgs.runCommandLocal "quickshell-config" { } ''
    mkdir -p $out
    cp -r --no-preserve=mode,ownership ${quickshellConfigSrc}/* $out/
    chmod -R u+rwX $out
    mkdir -p $out/ii/modules/common
    install -m644 -T ${quickshellConfigSrc}/ii/modules/common/Appearance.qml $out/ii/modules/common/Appearance.qml

    # Qt6 removed Qt Graphical Effects; this theme still imports `Qt5Compat.GraphicalEffects`.
    # Provide a minimal compatibility QML module under the config root so the imports resolve.
    mkdir -p $out/ii/Qt5Compat/GraphicalEffects

    cat > $out/ii/Qt5Compat/GraphicalEffects/qmldir <<'EOF'
module Qt5Compat.GraphicalEffects

OpacityMask 1.0 OpacityMask.qml
DropShadow 1.0 DropShadow.qml
ColorOverlay 1.0 ColorOverlay.qml
RadialGradient 1.0 RadialGradient.qml
Desaturate 1.0 Desaturate.qml
EOF

    cat > $out/ii/Qt5Compat/GraphicalEffects/OpacityMask.qml <<'EOF'
import QtQuick
import QtQuick.Effects

/*
  Compatibility shim for the removed Qt Graphical Effects module.
  The upstream theme imports `Qt5Compat.GraphicalEffects` and uses `OpacityMask`
  primarily as a `layer.effect`.
*/
MultiEffect {
    // When used as `layer.effect`, Hypr/Qt provides `source` automatically.
    maskEnabled: true
}
EOF

    cat > $out/ii/Qt5Compat/GraphicalEffects/DropShadow.qml <<'EOF'
import QtQuick
import QtQuick.Effects

/*
  Compatibility shim for `DropShadow`.
  Supports the common properties used by the Illogical Impulse config.
*/
MultiEffect {
    // Qt Graphical Effects API compatibility
    property real horizontalOffset: 0
    property real verticalOffset: 0
    property real radius: 8
    property int samples: 0
    property color color: "#80000000"

    shadowEnabled: true
    shadowColor: color
    shadowBlur: radius
    shadowHorizontalOffset: horizontalOffset
    shadowVerticalOffset: verticalOffset
}
EOF

    cat > $out/ii/Qt5Compat/GraphicalEffects/ColorOverlay.qml <<'EOF'
import QtQuick
import QtQuick.Effects

/*
  Compatibility shim for `ColorOverlay`.
  Expected usage:
    ColorOverlay { source: someItem; color: "#RRGGBB" }
*/
MultiEffect {
    // Qt Graphical Effects API compatibility
    property color color: "transparent"

    // MultiEffect has a `source` property that will be set by the theme.
    colorization: 1.0
    colorizationColor: color
}
EOF

    cat > $out/ii/Qt5Compat/GraphicalEffects/Desaturate.qml <<'EOF'
import QtQuick
import QtQuick.Effects

/*
  Compatibility shim for `Desaturate`.
*/
MultiEffect {
    // Qt Graphical Effects API compatibility
    property real desaturation: 0.0

    // MultiEffect has a `source` property that will be set by the theme.
    desaturation: desaturation
}
EOF

    cat > $out/ii/Qt5Compat/GraphicalEffects/RadialGradient.qml <<'EOF'
import QtQuick

/*
  Compatibility shim for `RadialGradient` using Canvas.
  The theme uses the Qt Graphical Effects API:

    RadialGradient {
      anchors.fill: parent
      gradient: Gradient { GradientStop { ... } }
    }
*/
Item {
    id: root

    // Qt Graphical Effects API compatibility
    property Gradient gradient

    implicitWidth: 0
    implicitHeight: 0

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        antialiasing: true

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            const w = width
            const h = height
            if (w <= 0 || h <= 0) return

            const cx = w / 2
            const cy = h / 2
            const r = Math.max(w, h) / 2

            const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, r)

            const stops = (root.gradient && root.gradient.stops) ? root.gradient.stops : []
            for (let i = 0; i < stops.length; i++) {
                const stop = stops[i]
                g.addColorStop(stop.position, stop.color)
            }

            ctx.fillStyle = g
            ctx.fillRect(0, 0, w, h)
        }
    }

    function repaint() {
        canvas.requestPaint()
    }

    onWidthChanged: repaint()
    onHeightChanged: repaint()
    onGradientChanged: repaint()

    Component.onCompleted: repaint()
}
EOF
  '';
in {
  options.quickshell.enable = lib.mkEnableOption "Enable QuickShell bar setup";

  config = lib.mkIf cfg.enable {
    # GTK/Qt are handled by the user's session or system configuration.
    # Keep only Home Manager settings below.

    home.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "~/.local/state/quickshell/.venv";
      QS_CONFIG_NAME = qsConfigName; # Default QuickShell configuration directory to run
      # Ensure QuickShell and other Qt apps use US month/day date formatting
      LC_TIME = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      # Cursor theme (set to a sensible default; install a matching cursor package if needed)
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";
    };

    # Make these available to the graphical/systemd user session too (Hyprland exec-once
    # processes won't necessarily read shell profile variables).
    systemd.user.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "~/.local/state/quickshell/.venv";
      QS_CONFIG_NAME = qsConfigName;
      LC_TIME = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";
    };

    # Keep the shell running and auto-restart if it dies.
    systemd.user.services.quickshell = {
      Unit = {
        Description = "QuickShell (Wayland shell)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Environment = [
          "QS_CONFIG_NAME=${qsConfigName}"
          "ILLOGICAL_IMPULSE_VIRTUAL_ENV=~/.local/state/quickshell/.venv"
        ];
        ExecStart = "${quickshellWrapped}/bin/qs -c ${qsConfigName}";
        Restart = "on-failure";
        RestartSec = "500ms";
      };
      Install = { };
    };

    home.packages = with pkgs; [
      quickshellWrapped
      kdePackages.kdialog
      kdePackages.qt5compat
      kdePackages.qtbase
      kdePackages.qtdeclarative
      kdePackages.qtimageformats
      kdePackages.qtmultimedia
      kdePackages.qtpositioning
      kdePackages.qtquicktimeline
      kdePackages.qtsensors
      kdePackages.qtsvg
      kdePackages.qttools
      kdePackages.qttranslations
      kdePackages.qtvirtualkeyboard
      kdePackages.qtwayland
      kdePackages.syntax-highlighting
      # Monitor control
      ddcutil
      # Clipboard history for QuickShell
      cliphist
      wl-clipboard
      # Fonts for icons/text used by the QuickShell theme
      material-symbols
      google-fonts
      nerd-fonts.space-mono
      nerd-fonts.jetbrains-mono
    ];

    xdg.configFile."quickshell".source = quickshellConfig;
  };
}

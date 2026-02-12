{ config, pkgs, lib, ... }:

# Minimal Hyprland module copied from temp flake; cleaned to avoid changing DMs or users
let
  hyprConfig = ./configs/xdg/hypr;
in {
  config = lib.mkMerge [
    (lib.mkIf config.hyprlandAddon.enable {
      # If the wrapper sets programs.hyprland, keep it in that module.
      # `hyprlandAddon` imports this module only when the add-on is enabled.
      programs.hyprland = {
        enable = true;
        # safe defaults copied from main configuration; these do not enable DMs or users
        xwayland.enable = true;
        withUWSM = false;
      };

      # Required for a functional Wayland desktop (auth prompts, portals, screensharing, etc.)
      security.polkit.enable = true;
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      };

      services.pipewire.enable = true;
      services.pipewire.alsa.enable = true;
      services.pipewire.alsa.support32Bit = true;
      services.pipewire.pulse.enable = true;
      services.pipewire.jack.enable = true;
      services.pipewire.wireplumber.enable = true;
      services.acpid.enable = true;
      services.acpid.lidEventCommands = ''
        /etc/xdg/hypr/lid-lock.sh
      '';

      # Start hypridle in the user session to manage idle locking and suspend hooks
      systemd.user.services.hypridle = {
        description = "Hyprland idle daemon (hypridle)";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.hypridle}/bin/hypridle --config /etc/xdg/hypr/hypridle.conf";
          Restart = "always";
        };
      };

      # Start Ulauncher in the user session to ensure it sees Nix packages
      systemd.user.services.ulauncher = {
        description = "Ulauncher application launcher";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
          # systemd does not expand "$PATH" in Environment=; set a complete PATH.
          # Include system + per-user Nix profiles so Ulauncher can discover binaries.
          Environment = [
            "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:%h/.nix-profile/bin"
            # Ensure launchers can see .desktop entries from Nix profiles and Flatpak.
            # - NixOS: /run/current-system/sw/share/applications
            # - Flatpak: /var/lib/flatpak/exports/share/applications and ~/.local/share/flatpak/exports/share/applications
            "XDG_DATA_DIRS=/run/current-system/sw/share:/etc/profiles/per-user/%u/share:/nix/var/nix/profiles/default/share:%h/.nix-profile/share:/var/lib/flatpak/exports/share:%h/.local/share/flatpak/exports/share:/usr/local/share:/usr/share"
            # Some GNOME apps set OnlyShowIn=GNOME; include GNOME so they appear in app launchers.
            "XDG_CURRENT_DESKTOP=Hyprland:GNOME"
            "XDG_SESSION_DESKTOP=Hyprland"
            "XDG_SESSION_TYPE=wayland"
          ];
          Restart = "always";
        };
      };

      # Allow hyprlock to authenticate via PAM
      security.pam.services.hyprlock = {};

      # Many launchers use GLib/GIO app discovery, which relies on XDG variables.
      # Keep this global set minimal and absolute-path-only (no $HOME expansion).
      environment.sessionVariables = {
        XDG_DATA_DIRS = lib.mkForce "/run/current-system/sw/share:/nix/var/nix/profiles/default/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share";
        XDG_CURRENT_DESKTOP = lib.mkDefault "Hyprland:GNOME";
        XDG_SESSION_DESKTOP = lib.mkDefault "Hyprland";
        XDG_SESSION_TYPE = lib.mkDefault "wayland";
      };

      environment.systemPackages = with pkgs; [
        hyprpaper
        kitty
        libnotify
        mako
        python3
        python3Packages.requests
        python3Packages.pip
        qt5.qtwayland
        qt6.qtwayland
        swayidle
        swaylock-effects
        wlogout
        wl-clipboard
        waypaper
        playerctl
        brightnessctl
        pamixer
        pavucontrol
      ];
    })
    (lib.mkIf (config.hyprlandAddon.enable && config.hyprlandAddon.deploySystemConfigs) {
      environment.etc."xdg/hypr".source = hyprConfig;
    })
  ];
}

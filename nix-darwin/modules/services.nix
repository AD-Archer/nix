{ config, pkgs, lib, ... }:
let
  user = config.system.primaryUser;
  userHome = "/Users/${user}";
  repoRoot = "${userHome}/nix/nix-darwin";
  shellPath = "/usr/bin:/bin:/usr/sbin:/sbin";
  sketchybarPath = lib.makeBinPath [
    pkgs.sketchybar
    pkgs.yabai
    pkgs.bash
    pkgs.jq
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gawk
  ];
  bordersPath = lib.makeBinPath [
    pkgs.jankyborders
    pkgs.coreutils
  ];
  hackNerdFont = "${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/Hack/HackNerdFont-Bold.ttf";
in
{
  environment.systemPackages = [
    pkgs.sketchybar
    pkgs.jankyborders
  ];

  # Keep the stock macOS menu bar out of the way when SketchyBar is running.
  system.defaults = {
    NSGlobalDomain._HIHideMenuBar = true;
    dock = {
      autohide = true;
      "autohide-delay" = 0.0;
      "autohide-time-modifier" = 0.15;
      "mru-spaces" = false;
      "show-recents" = false;
      tilesize = 40;
    };
    spaces."spans-displays" = false;
  };

  launchd.user.agents = {
    sketchybar = {
      path = [
        pkgs.sketchybar
        pkgs.yabai
        pkgs.bash
        pkgs.jq
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gawk
      ];
      environment.HACK_NERD_FONT = hackNerdFont;
      environment.PATH = "${shellPath}:${sketchybarPath}";
      serviceConfig = {
        KeepAlive = true;
        ProcessType = "Interactive";
        RunAtLoad = true;
        StandardOutPath = "${userHome}/Library/Logs/sketchybar.log";
        StandardErrorPath = "${userHome}/Library/Logs/sketchybar.err.log";
      };
      script = ''
        export CONFIG_DIR="${repoRoot}/sketchybar"
        exec ${pkgs.sketchybar}/bin/sketchybar --config "${repoRoot}/sketchybar/sketchybarrc"
      '';
    };

    jankyborders = {
      path = [
        pkgs.jankyborders
        pkgs.coreutils
      ];
      environment.PATH = "${shellPath}:${bordersPath}";
      serviceConfig = {
        KeepAlive = true;
        ProcessType = "Interactive";
        RunAtLoad = true;
        StandardOutPath = "${userHome}/Library/Logs/jankyborders.log";
        StandardErrorPath = "${userHome}/Library/Logs/jankyborders.err.log";
      };
      script = ''
        exec ${pkgs.runtimeShell} "${repoRoot}/borders/bordersrc"
      '';
    };
  };

  services = {
    openssh.enable = true;

    yabai = {
      enable = true; # Set to true if you want a tiling window manager
      package = pkgs.yabai;
      enableScriptingAddition = true;
      config = {
        layout = "bsp";
        auto_balance = "on";
        window_placement = "second_child";
        window_gap = 10;
        top_padding = 15; #45
        bottom_padding = 10;
        left_padding = 10;
        right_padding = 10;
      };
    };
  };
}

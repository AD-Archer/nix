{ config, pkgs, lib, ... }:
let
  user = config.system.primaryUser;
  userHome = "/Users/${user}";
  repoRoot = "${userHome}/nix/nix-darwin";
  shellPath = "/usr/bin:/bin:/usr/sbin:/sbin";
  sketchybarPath = lib.makeBinPath [
    pkgs.sketchybar
    pkgs.yabai
    pkgs.lua
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
        pkgs.lua
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
        exec ${pkgs.sketchybar}/bin/sketchybar
      '';
    };

    sketchybarLua = {
      path = [
        pkgs.sketchybar
        pkgs.yabai
        pkgs.lua
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
        StandardOutPath = "${userHome}/Library/Logs/sketchybar-lua.log";
        StandardErrorPath = "${userHome}/Library/Logs/sketchybar-lua.err.log";
      };
      script = ''
        export CONFIG_DIR="${repoRoot}/sketchybar"
        LUA_HOME="${userHome}/.local/share/sketchybar_lua"

        if [ ! -x "$LUA_HOME/lua" ] || [ ! -f "$LUA_HOME/sketchybar.so" ]; then
          /bin/rm -rf /tmp/SbarLua
          /usr/bin/git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua
          /usr/bin/perl -0pi -e 's/cd \$\(LUA_DIR\) && make/cd \$\(LUA_DIR\) && make generic/' /tmp/SbarLua/makefile
          (cd /tmp/SbarLua && /usr/bin/make install)
          /bin/mkdir -p "$LUA_HOME"
          /bin/cp /tmp/SbarLua/lua-5.5.0/src/lua "$LUA_HOME/lua"
          /bin/rm -rf /tmp/SbarLua
        fi

        while ! ${pkgs.sketchybar}/bin/sketchybar --query bar >/dev/null 2>&1; do
          sleep 1
        done

        exec "$LUA_HOME/lua" "${repoRoot}/sketchybar/sketchybarrc"
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
        top_padding = 10;
        bottom_padding = 10;
        left_padding = 10;
        right_padding = 10;
      };
    };
  };
}

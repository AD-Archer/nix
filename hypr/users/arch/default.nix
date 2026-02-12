{ config, pkgs, lib, osConfig ? {}, inputs, ... }:

let
  hyprAddonEnabled = (osConfig ? hyprlandAddon) && (osConfig.hyprlandAddon.enable or false);
in

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell.enable = true;

  home.sessionVariables = {
    QS_CONFIG_NAME = "dms";

    # App launchers (rofi drun, etc.) discover apps via .desktop files.
    # On NixOS these live under /run/current-system/sw/share/applications, which is
    # only searched if XDG_DATA_DIRS includes /run/current-system/sw/share.
    XDG_DATA_DIRS = lib.mkDefault (
      "/run/current-system/sw/share"
      + ":/etc/profiles/per-user/${config.home.username}/share"
      + ":/nix/var/nix/profiles/default/share"
      + ":${config.home.homeDirectory}/.nix-profile/share"
      + ":/var/lib/flatpak/exports/share"
      + ":${config.home.homeDirectory}/.local/share/flatpak/exports/share"
      + ":/usr/local/share:/usr/share"
    );

    # Some GNOME apps are marked OnlyShowIn=GNOME.
    XDG_CURRENT_DESKTOP = lib.mkDefault "Hyprland:GNOME";
    XDG_SESSION_DESKTOP = lib.mkDefault "Hyprland";
    XDG_SESSION_TYPE = lib.mkDefault "wayland";
  };

  # Also propagate into the systemd user environment (many GUI launchers/services
  # are started by systemd --user, not by an interactive shell).
  systemd.user.sessionVariables = {
    XDG_DATA_DIRS = config.home.sessionVariables.XDG_DATA_DIRS;
    XDG_CURRENT_DESKTOP = config.home.sessionVariables.XDG_CURRENT_DESKTOP;
    XDG_SESSION_DESKTOP = config.home.sessionVariables.XDG_SESSION_DESKTOP;
    XDG_SESSION_TYPE = config.home.sessionVariables.XDG_SESSION_TYPE;
  };
  programs.dank-material-shell.systemd.enable = true;

  # Make `qs` able to find the DMS config by name (`qs -c dms`) via XDG config paths.
  xdg.configFile."quickshell/dms" = {
    source = "${inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.dms-shell}/share/quickshell/dms";
    recursive = true;
  };

  # Home Manager settings
  home.stateVersion = "25.11"; # Pin to a specific version for stability

  # Link configuration files from the 'dotfiles' directory
  home.file = {
  ".config/kitty".source = ../../dotfiles/kitty;
  ".config/nvim".source = ../../dotfiles/nvim;
  ".config/tmux".source = ../../dotfiles/tmux;
    ".config/hypr".source = ../../modules/hyprland/configs/xdg/hypr;
    # Note: SSH config/keys are managed outside Home Manager now
  };

  # Provide helper scripts in the user's profile (available in $HOME/.nix-profile/bin)
  home.packages = with pkgs; [
    (writeScriptBin "update-quickshell" ''#!/usr/bin/env bash
      exec /etc/nixos/scripts/update-quickshell.sh "$@"
    '')
    (writeScriptBin "update-system" ''#!/usr/bin/env bash
      exec /etc/nixos/scripts/update-system.sh "$@"
    '')
  ];

  # Configure Zsh with Oh My Zsh and Powerlevel10k theme
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
      styles = {
        command = "fg=green";
        builtin = "fg=cyan";
        alias = "fg=yellow";
        path = "fg=blue";
        "reserved-word" = "fg=magenta";
      };
    };
    plugins = [
      { name = "zsh-history-substring-search"; src = pkgs.zsh-history-substring-search; }
      { name = "zsh-you-should-use"; src = pkgs.zsh-you-should-use; }
      { name = "zsh-nix-shell"; src = pkgs.zsh-nix-shell; }
    ];
    shellAliases = {
      ll = "ls -l";
      bw = "flatpak run --command=bw com.bitwarden.desktop";
      cd = "z"; 
      oc = "opencode";
      claer = "clear";
      qs = "command qs";
      rebuild = "cd /etc/nixos && sudo nixos-rebuild switch";
      update-qs = "/etc/nixos/scripts/update-quickshell.sh";
      update-system = "/etc/nixos/scripts/update-system.sh";
    };
    oh-my-zsh = {
      enable = true;
      theme = "refined";
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "kubectl"
        "colored-man-pages"
        "extract"
        "history-substring-search"
        "sudo"
      ];
    };
    initContent = ''
      if [[ $- == *i* ]]; then
        pokemon-colorscripts --no-title -b -n charizard -f mega-y -s | fastfetch --logo -
      fi
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
    '';
  };

  # Enable Zoxide for smarter directory navigation
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Git identity (managed by Home Manager instead of manual global config)
  programs.git = {
    enable = true;
    settings = {
      user.name = "ad-archer";
      user.email = "antonioarcher.dev@gmail.com";
    };
  };

  # Rofi launcher configuration
  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Window";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
    };
  };

  # SSH is handled by the system/user directly (not Home Manager)

  # Let home-manager manage its own files
  programs.home-manager.enable = true;
}

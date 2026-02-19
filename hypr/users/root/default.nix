{ config, pkgs, ... }:

{
  # Home Manager settings
  home.stateVersion = "25.05"; # Pin to a specific version for stability

  # Link configuration files from the 'dotfiles' directory
  home.file = {
  ".config/kitty".source = ../../dotfiles/kitty;
  ".config/nvim".source = ../../dotfiles/nvim;
  ".config/tmux".source = ../../dotfiles/tmux;
    ".config/hypr".source = ../../modules/hyprland/configs/xdg/hypr;
  };

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
      cd = "z"; 
      claer = "clear";
      rebuild = "cd /etc/nixos && sudo nixos-rebuild switch";
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
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
    '';
  };

  # Enable Zoxide for smarter directory navigation
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Git identity for root sessions
  programs.git = {
    enable = true;
    userName = "ad-archer";
    userEmail = "antonioarcher.dev@gmail.com";
  };

  # Let home-manager manage its own files
  programs.home-manager.enable = true;
}

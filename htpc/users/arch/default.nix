{ config, pkgs, lib, ... }:

{
  home.username = "arch";
  home.homeDirectory = "/home/arch";
  programs.git = {
    enable = true;
    userName = "ad-archer";
    userEmail = "antonioarcher.dev@gmail.com";
  };
  home.stateVersion = "25.05";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "fwalch";
      plugins = [ "git" "docker" "docker-compose" "kubectl" "zoxide" "fzf" "npm" ];
    };
    shellAliases = {
      rebuild = "cd /etc/nixos && sudo nixos-rebuild switch --flake .#htpc";
      upgrade = "cd /etc/nixos && sudo nixos-rebuild switch --upgrade --flake .#htpc";
      cat = "batcat";
      cd = "z";
      ll = "eza -al --color=always --group-directories-first --icons";
      ls = "eza -a --color=always --group-directories-first --icons";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [ zoxide fzf eza bat pnpm nodejs ];

  home.file = {
  ".config/kitty".source = ../../dotfiles/kitty;
  ".config/nvim".source = ../../dotfiles/nvim;
  ".config/tmux".source = ../../dotfiles/tmux;
  ".ssh/config".source = ../../dotfiles/ssh/config;
  };
}

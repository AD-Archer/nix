{ config, pkgs, ... }:

{
  home.username = "arch";
  home.homeDirectory = "/home/arch";
  programs.git.enable = true;
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      check = "echo 'NixOS installed successfully'";
      rebuild = "cd /etc/nixos && sudo nixos-rebuild switch --flake .#htpc";
      "rebuild-htpc" = "cd /etc/nixos && sudo nixos-rebuild switch --flake .#htpc";
      upgrade = "cd /etc/nixos && sudo nixos-rebuild switch --upgrade --flake .#htpc";
      "rebuild-upgrade" = "cd /etc/nixos && sudo nixos-rebuild switch --upgrade --flake .#htpc";
    };
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "fwalch";
      plugins = [ "git" "docker" "docker-compose" "kubectl" "zoxide" "fzf" "npm" ];
    };
    shellAliases = {
      rebuild = "cd /etc/nixos && sudo nixos-rebuild switch --flake .#htpc";
      upgrade = "cd /etc/nixos && sudo nixos-rebuild switch --upgrade --flake .#htpc";
      "rebuild-upgrade" = "cd /etc/nixos && sudo nixos-rebuild switch --upgrade --flake .#htpc";
      cat = "batcat";
      cd = "z";
      ll = "eza -al --color=always --group-directories-first --icons";
      ls = "eza -a --color=always --group-directories-first --icons";
      la = "eza -l --color=always --group-directories-first --icons";
      lt = "eza -aT --color=always --group-directories-first --icons";
      "l." = "eza -a | grep -e '^\\.'";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # user-level packages (fzf, eza, bat, pnpm, nodejs, zoxide)
  home.packages = with pkgs; [ zoxide fzf eza bat pnpm nodejs ];

}

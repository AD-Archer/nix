{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    kitty
    gcc
    fastfetch
    fzf
    tmux
    curl
    btop
    bat
    lazygit
    git
    neovim
    pnpm
    nodejs
    vscode
    python3
  ];
}

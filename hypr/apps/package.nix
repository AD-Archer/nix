{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    kitty
    gcc
    fastfetch
    gpaste
    # pokemon-colorscripts  # Not in nixpkgs
    fzf
    # bitwarden-desktop  # Not in nixpkgs
    # dbvisualizer  # Not in nixpkgs
    # ulauncher  # Removed - requires building webkitgtk from source
    # linux-wallengine  # Not in nixpkgs
    # Terminal tools
    tmux
    curl
    btop
    bat
    lazygit
    # vimPlugins.nvchad  # Not available

    # Dev
    # codex  # Not in nixpkgs
    # nodePackages.vercel  # Not in nixpkgs
    # code-cursor  # Not in nixpkgs
    git
    neovim
    pnpm
    nodejs
    # vscode  # Not available
    python3
    opencode
    go
    rustc
    cargo
    lua
  ];
}

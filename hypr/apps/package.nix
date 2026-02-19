{ pkgs, ... }:

# environment.systemPackages for hypr configuration. Keep this file simple —
# if you want other flakes, add them to `hypr/flake.nix` inputs and reference
# them from the flake outputs. This module installs Brave browser.
{
  environment.systemPackages = with pkgs; [
    wget
    kitty
    gcc
    fastfetch
    gpaste
    # pokemon-colorscripts  # Not in nixpkgs
    fzf
    bitwarden-desktop  # Not in nixpkgs
    # dbvisualizer  # Not in nixpkgs
    # linux-wallengine  # Not in nixpkgs
    # Terminal tools
    tmux
    curl
    btop
    bat
    lazygit
    # vimPlugins.nvchad  # Not available
    vscode
    # Dev
    # codex  # Not in nixpkgs
    # nodePackages.vercel  # Not in nixpkgs
    # code-cursor  # Not in nixpkgs
    git
    neovim
    pnpm
    nodejs
    python3
    opencode
    go
    usbutils
    cargo
    lua

    brave
    fprintd
    #Rust
    rustup
    cargo
    rustc
    rustfmt



    #grave yard
    # ulauncher  # Removed - requires building webkitgtk from source

  ];

  # (end of environment.systemPackages)
}
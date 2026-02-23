{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    kitty
    gcc
    fastfetch
    ripgrep
    fzf
    tmux
    curl
    btop
    bat
    lazygit
    
    vesktop
    bitwarden
    git
    libratbag
    neovim
    jq
    tailscale
    pnpm
    piper
    nodejs
    vscode
    python3
    kdePackages.kwallet-pam  # PAM integration for KDE Wallet
    # NVIDIA and graphics related packages
    vulkan-loader
    vulkan-tools
    glxinfo
    mesa-demos
    mergerfs
    # 32-bit libraries for Steam compatibility
    # Note: hardware.graphics.enable32Bit provides most 32-bit libs
    # Additional packages if needed can be added here
  ];
}

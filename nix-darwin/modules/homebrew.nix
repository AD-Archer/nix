{ config, pkgs, ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    global = {
      brewfile = true;
      lockfiles = false;  # kept false to avoid `--no-lock` incompat issues
    };
    # Taps - only add custom taps; avoid tapping homebrew/core or homebrew/cask (Homebrew handles them automatically)
    taps = [
      "siderolabs/tap" 
      "tw93/tap"
      "ad-archer/tap"
    ];
    brews = [
      "mas"  # Mac App Store CLI - kept in Homebrew for managing MAS apps
      "mole"
      "openssl@3"
      "libiconv"
      "just"
      "opencode"
      "yt-dlp"
      "libusb"
      "openssl"
      "lsd"
      "infisical"
      "ollama"
      "atuin"
      "direnv"
      "p7zip"
    ];

    # GUI apps (casks). Keep these as casks since they are apps (not CLI tools).
    casks = [
      # Media & multimedia
      "vlc"
      "slack"
      "vesktop"
      "zoom"                     
      "mp3tag"
      "raycast"
      "postman"
      "claude"
      "joplin"
      "jordanbaird-ice"
      "rustysound"
      "visual-studio-code"

      # Utilities
      "tailscale-app"
      "obs"
      "appcleaner"                
      "the-unarchiver"            
      # "raspberry-pi-imager"       
      "dbvisualizer"              
      # Networking
      "tailscale-app"
      "altserver"     
      "brave-browser"          
    ];

    masApps = {
    #   "Slack" = 803453959;
      "bitwarden" = 1352778147;
      "homea-menu bar"= 6758070650; 
      "home assistant" = 1099568401;
      "Notch" = 6737410946;
    };
  };
}

{ config, lib, pkgs, ...}:

{
 imports = 
  [
  ./hardware-configuration.nix
  ./apps/firewall.nix
  ./modules/hyprland-addon.nix
  ./nix.nix
  ./modules/display-manager.nix
  ]; 

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 20 * 1024;
  } ];


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hypr";
  networking.networkmanager.enable = true;

  # Let PipeWire own audio; legacy Pulseaudio daemon stays off. (sound.enable is deprecated.)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  time.timeZone = "America/New_York";
  services.getty.autologinUser = "arch";
  
  # Hyprland is managed by the add-on module (see `modules/hyprland/*`).
  # If you want hyprland enabled, set `hyprlandAddon.enable = true;` below.


  users.users.arch = {
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" ];
  shell = pkgs.zsh;
  packages = with pkgs; [
       tree
     ];
    };
  users.users.root.shell = pkgs.zsh;

  programs.zoxide.enable = true;
  programs.zsh.enable = true;
  programs.zoxide.enableZshIntegration = true;
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
};


  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.stateVersion = "25.11";

  # Display manager configuration moved to ./modules/display-manager.nix
  # See ./modules/display-manager.nix for SDDM/GDM and SDDM theme setup
  
  # Explicitly enable Hyprland so GDM has a launchable session and the binary is on PATH
  programs.hyprland.enable = true;
  services.desktopManager.gnome.enable = true;
  services.desktopManager.gnome.sessionPath = [ pkgs.gpaste ];
  programs.gpaste.enable = true;
  # Keep GNOME but drop its default terminal/browser
  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    gnome-terminal
    epiphany  # GNOME Web
    gnome-software
    # Exclude GNOME apps we prefer not to use under Hyprland
    gnome-calendar
    gnome-maps
    geary  # GNOME Mail
    
  ];

  # Ensure PAM has a service entry for gnome-keyring so login unlocks the login keyring
  security.pam.services.gnome-keyring = {};
  services.tailscale.enable = true; 
  services.flatpak.enable = true;
  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # SDDM theme, packages, and install script moved to ./modules/display-manager.nix
  # See ./modules/display-manager.nix for theme and SDDM-related configuration
  


  services.logind = {
    settings = {
      Login = {
        # Let logind handle lid close so the machine actually sleeps,
        # and hypridle can run its before/after sleep hooks reliably.
        HandlePowerKey = "ignore";
        HandleLidSwitch = "hibernate";
        HandleLidSwitchExternalPower = "suspend";
        # Common default: do not suspend when docked/closed with external display.
        HandleLidSwitchDocked = "ignore";
      };
    };
  };

  # -- Hyprland Add-on --
  # This integrates the local hyprland add-on as an optional module. It will import and
  # enable only the `hyprland` and `packages` modules from `./modules/hyprland`.
  # It DOES NOT automatically enable any display manager or create users.
  # To activate, set `hyprlandAddon.enable = true;` below.
  hyprlandAddon.enable = true;

  # Auto git backup of /etc/nixos after successful activation (e.g., nixos-rebuild switch)
  system.activationScripts.autoBackup = ''
    if [ -x /etc/nixos/scripts/auto-backup.sh ]; then
      # Run as arch so pushes use the user's creds/config
      /run/wrappers/bin/su -s ${pkgs.bash}/bin/bash arch -c /etc/nixos/scripts/auto-backup.sh
    fi
  '';
}

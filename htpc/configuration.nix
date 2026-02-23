{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "htpc";
  networking.networkmanager.enable = true;

  # Make sure Intel firmware is available
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Core Bluetooth stack
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # PipeWire + BlueZ for audio (if you use PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  time.timeZone = "America/New_York";

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.displayManager.ly.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable XWayland for X11 app compatibility on Wayland
  programs.xwayland.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable 32-bit support for Steam and other applications
  hardware.graphics.enable32Bit = true;

  # Enable KDE Wallet PAM integration to unlock wallet on login
  security.pam.services.ly.kwallet.enable = true;
  security.pam.services.ly.kwallet.forceRun = true;

    environment.plasma6.excludePackages = with pkgs; [
    libsForQt5.konsole
    
  ];


  # Ensure the system provides zsh so users with zsh as their login shell
  # will have the expected runtime environment (this satisfies the
  # builtin assertion when users.users.<name>.shell = pkgs.zsh).
  programs.zsh.enable = true;

  users.users.arch = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Enable Flatpak support system-wide
  services.flatpak.enable = true;
  services.tailscale.enable = true; 
  services.ratbagd.enable = true;


  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}

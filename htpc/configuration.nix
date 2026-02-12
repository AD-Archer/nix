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

  time.timeZone = "America/New_York";

  services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.desktopManager.plasma6.enable = true;

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

  programs.firefox.enable = true;

  # Enable Flatpak support system-wide
  services.flatpak.enable = true;


  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}

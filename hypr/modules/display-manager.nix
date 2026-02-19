{ config, lib, pkgs, ... }:

{
  # Display manager and SDDM theme config

  #services.xserver.enable = true;
  #
  # services.displayManager = {
  #   sddm = {
  #     enable = true;
  #     wayland.enable = true;
  #     theme = "sugar-dark";
  #   };
  #   sessionPackages = [ pkgs.hyprland ];
  # };
  #

  # Use explicit pkgs.* references to avoid evaluation-time undefined variable errors
  environment.systemPackages = [
    pkgs.sddm-sugar-dark
    pkgs.libsForQt5.qt5.qtgraphicaleffects
    pkgs.git
    pkgs.qt6.qtsvg
    pkgs.qt6.qtvirtualkeyboard
    pkgs.qt6.qtmultimedia
  ];
}

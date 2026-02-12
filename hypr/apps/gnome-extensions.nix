{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs.gnomeExtensions; [
    # Essential extensions (verified names)
    appindicator
    clipboard-indicator
    #dash-to-dock
    gsconnect
    sound-output-device-chooser
    
    # Popular productivity
    caffeine
    ulauncher-toggle
    
    # Working alternatives
    quick-settings-tweaker
    just-perfection
    blur-my-shell
  ];
}


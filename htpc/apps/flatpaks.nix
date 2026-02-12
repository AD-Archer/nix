{ config, pkgs, lib, ... }:
{
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];

  services.flatpak.packages = [
    "app.zen_browser.zen"
    "com.slack.Slack"
    "com.getpostman.Postman"
    "com.obsproject.Studio"
    "org.gimp.GIMP"
    "io.github.qwersyk.Newelle"
    "org.x.Warpinator"
    "us.zoom.Zoom"
  ];
  services.flatpak.update.onActivation = true;
  services.flatpak.uninstallUnmanaged = true;
}

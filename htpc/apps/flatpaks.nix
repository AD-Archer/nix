{ config, pkgs, lib, ... }:
{
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }
  {
    # Personal remote 
    name = "adarcher-rustysound";
    location = "https://ad-archer.github.io/linux-packages/rustysound.flatpakrepo";
  }];

  services.flatpak.packages = [
    "com.brave.Browser"
    "com.slack.Slack"
    "com.getpostman.Postman"
    "com.valvesoftware.Steam"
    "com.obsproject.Studio"
    "org.prismlauncher.PrismLauncher"
    "org.gimp.GIMP"
    "io.github.qwersyk.Newelle"
    "org.x.Warpinator"
    "us.zoom.Zoom"
    # Music
    {
      appId = "app.adarcher.rustysound";
      origin = "adarcher-rustysound";
    }
  ];
  services.flatpak.update.onActivation = true;
  services.flatpak.uninstallUnmanaged = true;
}

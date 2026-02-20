{ config, pkgs, lib, ... }:
{
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
    {
      # Personal remote 
      name = "adarcher-rustysound";
      location = "https://ad-archer.github.io/linux-packages/rustysound.flatpakrepo";
    }
  ];

  services.flatpak.packages = [
    # Browsers
    
    # Communication
    "dev.vencord.Vesktop"
    "com.slack.Slack"

    # Productivity
    "com.getpostman.Postman"
    "com.obsproject.Studio"
    "org.onlyoffice.desktopeditors"
    "org.gimp.GIMP"
    "io.gitlab.adhami3310.Impression"
    "org.gnome.Todo"
    "io.github.qwersyk.Newelle"
    "io.github.Foldex.AdwSteamGtk"
    "org.flatpak.Builder"

    # Gaming
    "org.vinegarhq.Sober"
    "com.usebottles.bottles"
    "io.mrarm.mcpelauncher"
    "com.mojang.Minecraft"
    "com.pokemmo.PokeMMO"
    "com.atlauncher.ATLauncher"
    "com.github.appadeia.Taigo"


    # Media
    "io.github.mhogomchungu.media-downloader"

    # Utilities
    "org.kde.filelight"
    "com.github.tchx84.Flatseal"
    "io.github.giantpinkrobots.flatsweep"
    "io.github.realmazharhussain.GdmSettings"
    "org.gnome.Extensions"
    "io.github.pwr_solaar.solaar"
    "org.x.Warpinator"

    # Video Conferencing
    "us.zoom.Zoom"

    # Music
    {
      appId = "app.adarcher.rustysound";
      origin = "adarcher-rustysound";
    }

    # Graveyard
    #"app.zen_browser.zen"

  ];
  services.flatpak.overrides = {
    "io.github.qwersyk.Newelle" = {
      Context.filesystems = [ "home" ];
      "Session Bus Policy"."org.freedesktop.Flatpak" = "talk";
    };
  };
  services.flatpak.update.onActivation = true;
  services.flatpak.uninstallUnmanaged = true;  # Removes undeclared apps on rebuild
}

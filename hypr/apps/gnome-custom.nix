{ config, pkgs, lib, ... }:

{
  # Enable dconf for GNOME settings
  programs.dconf.enable = true;

  # Custom GNOME keybinds via systemd user service
  systemd.user.services.gnome-keybinds = {
    description = "Custom GNOME Keybinds";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      #!/usr/bin/env bash
      sleep 5  # Wait for GNOME to fully load
      
      # Ctrl+Space: Ulauncher toggle (if installed)
      gsettings set org.gnome.shell.keybindings toggle-application-view "['<Control>space']" 2>/dev/null || true
      
      # Ctrl+Alt+T: Kitty terminal
      gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
      gsettings set /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'
      gsettings set /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'kitty'
      gsettings set /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Control><Alt>t'
    '';
  };
}

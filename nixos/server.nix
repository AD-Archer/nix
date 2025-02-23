{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  # Server-specific boot configuration
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";  # Adjust this according to your disk
    };
  };

  # Network configuration
  networking = {
    hostName = "ubuntu-server";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];  # Common server ports
    };
  };

  # Server-focused packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    curl
    wget
    htop
    tmux
    ufw
    fail2ban
    # Server-specific packages can go here
  ];

  # Server services
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    fail2ban.enable = true;
  };

  # System settings
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User configuration
  users.users.archer = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here
      "ssh-rsa AAAA..."
    ];
  };

  # Enable zsh
  programs.zsh.enable = true;

  system.stateVersion = "23.11";
}
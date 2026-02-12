{ config, lib, pkgs, ... }:

{
  # Enable NixOS default firewall
  networking.firewall.enable = true;

  # Allow SSH on port 22 and Warpinator on port 42000
  networking.firewall.allowedTCPPorts = [ 22 42000 ];

  # Allow KDE Connect UDP ports 1714-1764
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  # Trust the Tailscale interface to allow all traffic from tailnet
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Enable OpenSSH for SSH access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;  # Use keys only
    };
  };
}
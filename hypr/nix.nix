{ config, lib, pkgs, ... }:

{
  # Nix store maintenance: run GC automatically and prune builds older than 5 days.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 5d";
  };

  # Also optimise the store periodically to deduplicate paths.
  nix.optimise.automatic = true;

  # General Nix daemon settings.
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
}

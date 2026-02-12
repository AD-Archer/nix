{
  description = "My Nixos Flakes Repository";

  # Keep this flake as the existing system flake but also expose other
  # flakes in subfolders (Nixos/, nix-darwin/) so this repository can act
  # as an aggregator for all flakes in-tree.
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

  # Local sub-flakes (kept as separate flakes so they remain reusable).
  htpc = {
    url = "path:./htpc";
    inputs.nix-flatpak.follows = "nix-flatpak";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
  hypr = {
    url = "path:./hypr";
    inputs.nix-flatpak.follows = "nix-flatpak";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
  # expose the nix-darwin folder under the `mac` input for a cleaner name
  mac = { url = "path:./nix-darwin"; };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, htpc, ... }: {
  # Combine NixOS configurations from in-tree subflakes so the root
  # flake exposes them all (e.g. `.#htpc`, `.#hypr`). The `or {}`
  # guards handle subflakes that don't export `nixosConfigurations`.
  nixosConfigurations = (htpc.nixosConfigurations or {}) // (inputs.hypr.nixosConfigurations or {});

  # Re-export darwinConfigurations from the nix-darwin subflake so you can
  # reference macOS configs from the repository root (e.g. `./#mac`).
  darwinConfigurations = let nd = inputs.mac; in (nd.darwinConfigurations or {}) // (if builtins.hasAttr "darwinConfigurations" nd && builtins.hasAttr "mac" nd.darwinConfigurations then { mac = nd.darwinConfigurations.mac; } else {});

    # (no additional top-level `packages`/`apps` to re-export from `htpc`)
  };
}

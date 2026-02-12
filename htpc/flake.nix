{
  description = "My desktop Nixos Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak ? null, ... }: {
    nixosConfigurations.htpc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = (if nix-flatpak != null then [ nix-flatpak.nixosModules.nix-flatpak ./apps/flatpaks.nix ] else []) ++ [
        ./apps/package.nix
        ./apps/firewall.nix
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.arch = import ./users/arch/default.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}

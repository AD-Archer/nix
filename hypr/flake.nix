{
  description = "My Laptop Nixos Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-flatpak ? null, quickshell ? null, dms ? null, ... }@inputs: {
    nixosConfigurations.hypr = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = (if nix-flatpak != null then [ nix-flatpak.nixosModules.nix-flatpak ./apps/flatpaks.nix ] else []) ++ [
        ./configuration.nix
        ./apps/package.nix
        ./apps/gnome-extensions.nix
        ./apps/gnome-custom.nix
        ./apps/ollama.nix
        ./apps/firewall.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.root = import ./users/root/default.nix;
            users.arch = import ./users/arch/default.nix;
            extraSpecialArgs = { inherit inputs; };
            # Avoid clobbering existing *.backup files; use a unique suffix
            backupFileExtension = "hm-bak";
          };
        }
      ];
    };
  };
}

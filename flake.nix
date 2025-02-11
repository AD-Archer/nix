{
  description = "My Default system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, nixpkgs }:
  let
    system = "aarch64-darwin"; # Define the system architecture
    pkgs = nixpkgs.legacyPackages.${system};
    configuration = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.neovim
        pkgs.neofetch
      ];

      nix.settings.experimental-features = "nix-command flakes";

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
    };
  in {
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      system = system; # <-- This is the crucial missing line!
      modules = [ configuration ];
    };

        apps.${system}.darwin-rebuild = {
          type = "app";
          program = "${pkgs.darwin.darwin-rebuild}/bin/darwin-rebuild";
        };
  };
}
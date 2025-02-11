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
    configuration = { pkgs, config, ... }: {
      environment.systemPackages = [
        pkgs.neovim
        pkgs.neofetch
        pkgs.git
        pkgs.neofetch
        pkgs.curl
        pkgs.mkalias




        # # pkgs.ghostty
        # pkgs.zoom-us
        # pkgs.obs-studio
        # pkgs.raycast
        # pkgs.upscayl
      ];


      # alais
      system.activationScripts.applications.text = let
  env = pkgs.buildEnv {
    name = "system-applications";
    paths = config.environment.systemPackages;
    pathsToLink = "/Applications";
  };
in
  pkgs.lib.mkForce ''
  # Set up applications.
  echo "setting up /Applications..." >&2
  rm -rf /Applications/Nix\ Apps
  mkdir -p /Applications/Nix\ Apps
  find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
  while read -r src; do
    app_name=$(basename "$src")
    echo "copying $src" >&2
    ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
  done
      '';
      

      nix.settings.experimental-features = "nix-command flakes";

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;

      

      # System services
      services = {
        # SSH service
        openssh.enable = true;
        
       
      };

      security.pam.enableSudoTouchIdAuth = true;

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
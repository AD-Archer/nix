{
  description = "My Default system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = { self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
  let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};

    configModule = { config, pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;

      # Homebrew configuration moved inside the module
      homebrew = {
        enable = true;  # Changed from enabled to enable
        brews = [
          "mas"
          "node"
          "python@3.13"
          "pipx"


        ];
        casks = [  # Fixed from casts to casks
          "cheatsheet"
          "altserver"
          "malwarebytes"
          "zen-browser"
          "mist"
          "vlc"
          "obs"
          "notion"
          "latest"
          "cleanmymac"
          "the-unarchiver"
          "qbittorrent"
          "tailscale"
          "capcut"
          "whisky"
        ];
        onActivation.autoUpdate = true;
        onActivation.cleanup = "zap";
        masApps = {
          "AnkiApp Flashcards" = 1366312254;
          "eero" = 1498025513;
          "Slack" = 803453959;
          

        };
      };

      environment.systemPackages = [
        pkgs.neovim
        pkgs.neofetch
        pkgs.git
        pkgs.curl
        pkgs.spotify
        pkgs.vscode
        pkgs.zoom-us
        pkgs.discord
        pkgs.appcleaner
      ];

      system.activationScripts.applications = {
        text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
          };
        in ''
          echo "Setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "Copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';
      };

      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      services.openssh.enable = true;
      security.pam.enableSudoTouchIdAuth = true;
    };

  in {
    darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        configModule
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "archer";
            autoMigrate = true;
            taps = {
              "homebrew/core" = homebrew-core;
              "homebrew/cask" = homebrew-cask;
              "homebrew/bundle" = homebrew-bundle;
            };
          };
        }
      ];
    };

    apps.${system}.darwin-rebuild = {
      type = "app";
      program = "${nix-darwin.legacyPackages.${system}.darwin-rebuild}/bin/darwin-rebuild";
    };
  };
}
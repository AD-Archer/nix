#darwin-rebuild switch --flake ~/nix#mac

{
  description = "My macbook flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = { self, nixpkgs, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, home-manager, ... }:
  let
    system = "aarch64-darwin";
    linuxSystem = "x86_64-linux";

    pkgs = nixpkgs.legacyPackages.${system};

    configModule = { config, pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;

      # Custom activation script to check for Homebrew before installation
      system.activationScripts.preActivation.text = ''
        # Check if Homebrew is already installed
        if [ -f "/opt/homebrew/bin/brew" ] || [ -f "/usr/local/bin/brew" ]; then
          echo "Homebrew is already installed. Skipping installation."
          export HOMEBREW_ALREADY_INSTALLED=1
        else
          echo "Homebrew not found. Will proceed with installation."
          export HOMEBREW_ALREADY_INSTALLED=0
        fi
      '';

      # Sketchybar setup script
      system.activationScripts.postActivation.text = ''
        # Set up Sketchybar configuration if it doesn't exist
        if [ ! -d "$HOME/.config/sketchybar" ]; then
          echo "Setting up Sketchybar configuration..."
          mkdir -p "$HOME/.config/sketchybar/plugins"
          
          # Copy example configuration
          if [ -d "/opt/homebrew/opt/sketchybar" ]; then
            cp "/opt/homebrew/opt/sketchybar/share/sketchybar/examples/sketchybarrc" "$HOME/.config/sketchybar/sketchybarrc"
            cp -r "/opt/homebrew/opt/sketchybar/share/sketchybar/examples/plugins/" "$HOME/.config/sketchybar/plugins/"
          elif [ -d "/usr/local/opt/sketchybar" ]; then
            cp "/usr/local/opt/sketchybar/share/sketchybar/examples/sketchybarrc" "$HOME/.config/sketchybar/sketchybarrc"
            cp -r "/usr/local/opt/sketchybar/share/sketchybar/examples/plugins/" "$HOME/.config/sketchybar/plugins/"
          fi
          
          # Make plugins executable
          find "$HOME/.config/sketchybar/plugins" -type f -exec chmod +x {} \;
          
          # Add shebang line to sketchybarrc if it doesn't have one
          if [ -f "$HOME/.config/sketchybar/sketchybarrc" ]; then
            if ! grep -q "^#!/bin/bash" "$HOME/.config/sketchybar/sketchybarrc"; then
              sed -i.bak '1i\
#!/bin/bash
' "$HOME/.config/sketchybar/sketchybarrc"
              rm -f "$HOME/.config/sketchybar/sketchybarrc.bak"
            fi
          fi
        else
          echo "Sketchybar configuration already exists. Skipping setup."
        fi
        
        # Note: We don't start Sketchybar here because the activation script runs as root
        # and Homebrew should not be run as root. Instead, use the sb-restart alias
        # after the system rebuild is complete.
        echo "NOTE: To start Sketchybar, run 'brew services start sketchybar' after the system rebuild is complete."
      '';

      # Homebrew configuration with all packages consolidated here
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap"; # Removes all unmanaged homebrew packages
          upgrade = true;
        };
        global = {
          brewfile = true;
          lockfiles = true;
        };
        taps = [
          "FelixKratz/formulae"
          # "homebrew/cask-fonts" # This tap is deprecated according to Homebrew
        ];
        brews = [
          # Development tools
          "mas"
          "node"
          "python@3.13"
          "pipx"
          "zsh-completions"
          "neovim"
          "git"
          "curl"
          "jq"
          "fd"
          "fzf"
          "bat"
          "htop"
          "tmux"
          "gh"           # GitHub CLI
          "ffmpeg"
          "ripgrep"
          "btop"
          "tree"
          "watch"
          "rsync"
          "neofetch"
          "ollama"
          # Sketchybar and dependencies
          "sketchybar"
        ];
        casks = [
          # Utilities
          "cheatsheet"
          "altserver"
          "malwarebytes"
          "mist"
          "vlc"
          "obs"
          "notion"
          "latest"
          "the-unarchiver"
          "qbittorrent"
          "tailscale"
          "ghostty"
          "raycast"       # Productivity
          "stats"         # System monitoring
          "appcleaner"    # App uninstaller
          "balenaetcher"  # USB image writer
          "spotify"
          "zoom"
          "discord"
          # Fonts for Sketchybar - using direct cask names without the tap prefix
          "homebrew/cask-fonts/font-hack-nerd-font"
          "sf-symbols"    # Moving sf-symbols from brews to casks where it belongs
        ];
        masApps = {
          "AnkiApp Flashcards" = 1366312254;
          "eero" = 1498025513;
          "Slack" = 803453959;
        };
      };

      # System packages installed via Nix - keeping only what's necessary for system functionality
      # and not available via Homebrew
      environment.systemPackages = with pkgs; [
        # Only keeping essential Nix packages that are needed for system functionality
        mkalias  # Needed for application linking
        zsh-powerlevel10k  # For Powerlevel10k ZSH theme
      ];

      # Improved application linking
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

      # Enhanced system defaults for better Mac experience
      system.defaults = {
        # Dock settings
        dock = {
          autohide = true;
          show-recents = false;
          mru-spaces = false;
          minimize-to-application = true;
          orientation = "bottom";
          tilesize = 48;
        };
        
        # Finder settings
        finder = {
          AppleShowAllExtensions = true;
          FXEnableExtensionChangeWarning = false;
          QuitMenuItem = true;
          _FXShowPosixPathInTitle = true;
          CreateDesktop = true;
          ShowPathbar = true;
          ShowStatusBar = true;
        };
        
        # Trackpad settings
        trackpad = {
          Clicking = true;
          TrackpadThreeFingerDrag = true;
          TrackpadRightClick = true;
        };
        
        # General UI/UX
        NSGlobalDomain = {
          AppleKeyboardUIMode = 3;
          ApplePressAndHoldEnabled = false;
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;
          "com.apple.swipescrolldirection" = false;
          "com.apple.keyboard.fnState" = true;
        };
        
        # Menu bar settings - hide the default menu bar for Sketchybar
        menuExtraClock.Show24Hour = false;
        menuExtraClock.ShowSeconds = false;
        
        # For macOS Sonoma and newer
        # controlCenter.AutoHide = true;  # This option is not supported in your version of nix-darwin
        
        # Note: To hide the default macOS menu bar, you need to do this manually:
        # For macOS Sonoma: System Settings -> Control Center -> Automatically hide and show the menu bar -> Always
        # For macOS Ventura: System Settings -> Desktop & Dock -> Automatically hide and show the menu bar -> Always
        # For Pre-Ventura: System Preferences -> Dock & Menu Bar -> Automatically hide and show the menu bar (checked)
        
        loginwindow.LoginwindowText = "Archer's Macbook 215-437-2912";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # System services
      services = {
        openssh.enable = true;
        nix-daemon.enable = true;
        yabai = {
          enable = false; # Set to true if you want a tiling window manager
          package = pkgs.yabai;
          enableScriptingAddition = true;
          config = {
            layout = "bsp";
            auto_balance = "on";
            window_placement = "second_child";
            window_gap = 10;
            top_padding = 32; # Increased to accommodate Sketchybar
            bottom_padding = 10;
            left_padding = 10;
            right_padding = 10;
            external_bar = "all:32:0"; # Format is "main:top:bottom", this reserves space for Sketchybar
          };
        };
        skhd = {
          enable = false; # Set to true if you want keyboard shortcuts for yabai
          package = pkgs.skhd;
        };
        # Sketchybar will be managed by Homebrew services instead
        # sketchybar = {
        #   enable = true;
        #   package = pkgs.sketchybar;
        # };
      };

      # Fonts - updated to use the new nerd-fonts namespace structure
      fonts = {
        packages = [
          pkgs.jetbrains-mono
          pkgs.fira-code
          pkgs.nerd-fonts.fira-code
          pkgs.noto-fonts
          pkgs.noto-fonts-emoji
        ] ++ (builtins.filter pkgs.lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));
      };

      # Nix settings - updated to use the correct optimization setting
      nix = {
        settings = {
          experimental-features = "nix-command flakes";
          trusted-users = ["root" "archer"];
        };
        optimise = {
          automatic = true;
        };
        gc = {
          automatic = true;
          interval = { Day = 7; };
          options = "--delete-older-than 30d";
        };
      };

      # System configuration
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      
      # Security
      security.pam.enableSudoTouchIdAuth = true;

      # Basic shell configuration without home-manager
      environment.shellAliases = {
        ll = "ls -la";
        update = "darwin-rebuild switch --flake ~/nix#mac";
        g = "git";
        gs = "git status";
        gc = "git commit";
        gp = "git push";
        gpl = "git pull";
        # Sketchybar aliases
        sb-restart = "brew services restart sketchybar";
        sb-start = "brew services start sketchybar";
        sb-stop = "brew services stop sketchybar";
        sb-edit = "$EDITOR ~/.config/sketchybar/sketchybarrc";
      };
      
      # Powerlevel10k ZSH theme configuration
      programs.zsh = {
        enable = true;
        promptInit = ''
          # Source powerlevel10k
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
        '';
        interactiveShellInit = ''
          # p10k instant prompt
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
          
          # Enable powerlevel10k instant prompt
          export ZSH_THEME="powerlevel10k/powerlevel10k"
        '';
      };
    };

  in {
    darwinConfigurations = {
      mac = nix-darwin.lib.darwinSystem {
        system = system;
        modules = [
          configModule
          # Temporarily disable nix-homebrew to avoid conflicts with existing installation
          # nix-homebrew.darwinModules.nix-homebrew
          # {
          #   nix-homebrew = {
          #     enable = true;
          #     enableRosetta = true;
          #     user = "archer";
          #     autoMigrate = true;
          #     mutableTaps = false;
          #     taps = {
          #       "homebrew/core" = homebrew-core;
          #       "homebrew/cask" = homebrew-cask;
          #       "homebrew/bundle" = homebrew-bundle;
          #     };
          #   };
          # }
          # Simplified approach without home-manager to avoid username conflicts
          {
            # Basic shell configuration without home-manager
            environment.shellAliases = {
              ll = "ls -la";
              update = "darwin-rebuild switch --flake ~/nix#mac";
              g = "git";
              gs = "git status";
              gc = "git commit";
              gp = "git push";
              gpl = "git pull";
            };
            
            # Powerlevel10k ZSH theme configuration
            programs.zsh = {
              enable = true;
              promptInit = ''
                # Source powerlevel10k
                source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
                # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
                [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
              '';
              interactiveShellInit = ''
                # p10k instant prompt
                if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                  source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
                fi
                
                # Enable powerlevel10k instant prompt
                export ZSH_THEME="powerlevel10k/powerlevel10k"
              '';
            };
          }
        ];
      };
    };

    # Expose the darwin-rebuild command as a flake app
    apps.aarch64-darwin.darwin-rebuild = {
      type = "app";
      program = "${nix-darwin.packages.aarch64-darwin.darwin-rebuild}/bin/darwin-rebuild";
    };

    nixosConfigurations.arch = nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      modules = [
        ./nixos/arch.nix
      ];
    };

    nixosConfigurations.ubuntu-server = nixpkgs.lib.nixosSystem {
      system = linuxSystem;
      modules = [
        ./nixos/server.nix
      ];
    };
  };
}
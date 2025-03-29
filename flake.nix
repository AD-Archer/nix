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
        # Remove Sketchybar configuration files
        if [ -d "$HOME/.config/sketchybar" ]; then
          echo "Removing Sketchybar configuration..."
          rm -rf "$HOME/.config/sketchybar"
        fi
        
        # Stop Sketchybar service if it's running and uninstall it
        if command -v brew >/dev/null 2>&1; then
          if brew services list | grep -q sketchybar; then
            echo "Stopping Sketchybar service..."
            brew services stop sketchybar
          fi
          
          if brew list | grep -q sketchybar; then
            echo "Uninstalling Sketchybar..."
            brew uninstall sketchybar
          fi
        fi
        
        # Reset menu bar settings to default
        defaults delete com.apple.menuextra 2>/dev/null || true
        killall SystemUIServer 2>/dev/null || true
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
          # "FelixKratz/formulae" # Removed Sketchybar tap
          # "homebrew/cask-fonts" # This tap is deprecated according to Homebrew
        ];
        brews = [
          # Development tools
          "mas"
          "node"
          "python@3.13"
          "pipx"
          "zsh-completions"
          "bitwarden-cli"
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
          "go"
          "lua"
          "luarocks"
          "watch"
          "rsync"
          "neofetch"
          "ollama"
          # Removed Sketchybar
        ];
        casks = [
          # Utilities
          "cheatsheet"
          "altserver"
          "malwarebytes"
          "mist"
          "vlc"
          "obs"
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
          # Removed Sketchybar fonts
          "sf-symbols"    # Keeping SF Symbols as it's generally useful
        ];
        masApps = {
          "AnkiApp-Flashcards" = 1366312254;
          "eero" = 1498025513;
          "Slack" = 803453959;
          "bitwarden"= 1352778147;
          "live-wallpapers"= 1552826194;
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
        
        # Menu bar settings - restored to show the default menu bar
        menuExtraClock.Show24Hour = false;
        menuExtraClock.ShowSeconds = false;
        
        # For macOS Sonoma and newer - uncomment if you're on Sonoma
        # controlCenter.AutoHide = false;
        
        # Note: If you manually hid the menu bar before, you'll need to manually show it again:
        # For macOS Sonoma: System Settings -> Control Center -> Automatically hide and show the menu bar -> Never
        # For macOS Ventura: System Settings -> Desktop & Dock -> Automatically hide and show the menu bar -> Never
        # For Pre-Ventura: System Preferences -> Dock & Menu Bar -> Automatically hide and show the menu bar (unchecked)
        
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
            top_padding = 10;
            bottom_padding = 10;
            left_padding = 10;
            right_padding = 10;
            external_bar = "off"; # Menu bar is now handled by macOS
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
        # Sketchybar aliases removed
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
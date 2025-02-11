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
        pkgs.git
        pkgs.neofetch
        pkgs.curl



        # # pkgs.ghostty
        # pkgs.zoom-us
        # pkgs.obs-studio
        # pkgs.raycast
        # pkgs.upscayl
      ];

      nix.settings.experimental-features = "nix-command flakes";

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;

      # # Automatic Updates
      # services.auto.update = {
      #   enable = true;
      #   frequency = "daily";  # or "hourly", "weekly", "monthly"
      #   channels = [
      #     {
      #       name = "nixpkgs-unstable";
      #       url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      #     }
      #   ];
      #   commitChanges = true; # Commit changes after update
      #   updateOptions = "--gc"; # Run garbage collection after updating
      # };

      # # Automatic Garbage Collection
      # services.auto.gc = {
      #   enable = true;
      #   frequency = "weekly"; # or "daily", "monthly"
      #   gcOptions = "--delete-older-than 30d"; # Adjust as needed
      #   afterUpdate = true; # Run GC after updates
      #   beforeUpdate = false; # Run GC before updates
      # };

      # # VSCode configuration
      # programs.vscode = {
      #   enable = true;
      #   package = pkgs.vscode;
      #   extensions = (with pkgs.vscode-extensions; [
      #     dracula-theme.theme-dracula
      #     pkief.material-icon-theme
      #     eamodio.gitlens
      #     donjayamanne.githistory
      #     github.vscode-pull-request-github
      #     ms-python.python
      #     tabnine.tabnine-vscode
      #     eg2.vscode-npm-script
      #     formulahendry.code-runner
      #     ritwickdey.liveserver
      #   ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      #     {
      #       name = "tabnine-vscode";
      #       publisher = "tabnine";
      #       version = "3.6.103";
      #       sha256 = "sha256-0000000000000000000000000000000000000000000="; # You'll need to get the correct sha
      #     }
      #   ];
      #   userSettings = {
      #     "workbench.colorTheme" = "Dracula";
      #     "workbench.iconTheme" = "material-icon-theme";
      #     "editor.fontFamily" = "'FiraCode Nerd Font', 'Droid Sans Mono', 'monospace'";
      #     "editor.fontLigatures" = true;
      #     "editor.formatOnSave" = true;
      #     "files.autoSave" = "afterDelay";
      #     "git.enableSmartCommit" = true;
      #     "git.confirmSync" = false;
      #     "python.formatting.provider" = "black";
      #     "python.linting.enabled" = true;
      #     "python.linting.pylintEnabled" = true;
      #     "liveServer.settings.donotShowInfoMsg" = true;
      #     "code-runner.runInTerminal" = true;
      #     "code-runner.saveFileBeforeRun" = true;
      #   };
      # };

      # # Enable Zsh system-wide
      # programs.zsh = {
      #   enable = true;
      #   ohMyZsh = {
      #     enable = true;
      #     theme = "powerlevel10k/powerlevel10k";
      #     plugins = [ 
      #       "git"
      #       "docker"
      #       "node"
      #       "npm"
      #       "sudo"
      #       "command-not-found"
      #       "colored-man-pages"
      #       "zsh-autosuggestions"
      #       "zsh-syntax-highlighting"
      #     ];
      #   };
      #   promptInit = ''
      #     # Enable Powerlevel10k instant prompt
      #     if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
      #       source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      #     fi

      #     source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      #     # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
      #     [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      #   '';
      #   interactiveShellInit = ''
      #     # p10k customization
      #     POWERLEVEL9K_MODE='nerdfont-complete'
      #     POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
      #     POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs time)
          
      #     # Useful aliases
      #     alias ls='exa --icons'
      #     alias ll='exa -l --icons'
      #     alias la='exa -la --icons'
      #     alias cat='bat'
      #     alias grep='rg'
      #     alias find='fd'
      #   '';
      # };

      # # User configuration
      # users.users.archer = {
      #   isNormalUser = true;
      #   shell = pkgs.zsh;
      #   home = "/home/archer";
      #   extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
      # };

      # System services
      services = {
        # SSH service
        openssh.enable = true;
        
       
      };

      
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
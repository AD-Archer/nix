{ config, lib, pkgs, ... }:

let
  # Use our local modules/hyprland so we can delete the temp flake later
  hyprlandModule = ./hyprland/hyprland.nix;
  hyprlandPackagesModule = ./hyprland/packages.nix;
in
{
  options.hyprlandAddon.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the local hyprland add-on modules from ./modules/hyprland.\nSet to true to enable programs.hyprland and associated packages, left as false by default to avoid accidentally switching display managers or adding users. This add-on intentionally does NOT import users.nix, services.sddm, or other modules that would change login/session configs.";
  };

  options.hyprlandAddon.deploySystemConfigs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "When true, install system-wide default hyprland configs to /etc/xdg/ so users without local configs get a working session. User-specific $HOME configs will still override these; kitty/nvim/tmux configs are not included.";
  };

  # Import hyprland & packages modules unconditionally, but let those modules
  # guard their effects with `config.hyprlandAddon.enable` (recommended to avoid
  # referencing `config` inside `imports`, which can create recursion)
  imports = [ hyprlandModule hyprlandPackagesModule ];
}

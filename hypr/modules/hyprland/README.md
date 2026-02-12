Hyprland add-on

This small module provides the Hyprland program and a curated set of system packages as a safe-side add-on for this NixOS configuration.

Key points:

- This add-on does NOT change display manager or user accounts (it does NOT import users.nix or services.sddm).
- It only adds packages and sets `programs.hyprland.enable = true` when enabled.

How to enable

1. Edit `/etc/nixos/configuration.nix` and set `hyprlandAddon.enable = true;` in the root config or optionally enable it via a per-host configuration.

2. `nixos-rebuild switch` to apply the changes.

Notes

- The GDM display manager and GNOME desktop are left intact by default. If you want to use a Hyprland session, choose it at the login screen (GDM) or change your display manager manually. The add-on does not enable SDDM or create additional users.
- Feel free to customize `modules/hyprland/packages.nix` to add or remove packages.

Default hyprland options enabled by the add-on: - `programs.hyprland.xwayland.enable = true;` - `programs.hyprland.withUWSM = true;`

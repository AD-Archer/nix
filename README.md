Repository-level aggregator for local flakes

This repository now exposes the in-tree flakes (examples: `Nixos/`, `nix-darwin/`) from the repository root so you can use a single flake reference for everything.

Usage

- List available targets: `nix flake show .`
- Rebuild a target quickly: `./rebuild #hypr`, `./rebuild #mac`, `./rebuild #htpc`

Notes

- The original `htpc` NixOS configuration (the flake that was already in this
  folder) was preserved — nothing was removed or renamed.
- Subflakes remain reusable on their own (you can still `--flake ./Nixos#hypr`).
- If you prefer separate histories for subflakes, keep using git submodules or
  subtrees; the aggregator works with both.

Repository-level aggregator for local flakes

This repository exposes the in-tree flakes (examples: `htpc/`, `hypr/`, `nix-darwin/`) from the repository root so you can use a single flake reference for everything. The `nix-darwin/` flake is exposed at the cleaner name `mac` from the repository root (so you can use `./#mac`).

Usage

- List available targets: `nix flake show .`
- Rebuild a target quickly: `./rebuild #hypr`, `./rebuild #mac`, `./rebuild #htpc`

Notes

- The HTPC configuration was moved to `htpc/`. Top-level compatibility files (`configuration.nix`, `home.nix`, `hardware-configuration.nix`) have been removed — use `./#htpc` instead.
- `hypr/` is included in the aggregator so `./#hypr` is available.
- Subflakes remain usable on their own (you can still `--flake ./hypr#hypr`).
- If you prefer separate histories for subflakes, keep using git submodules or subtrees; the aggregator works with both.

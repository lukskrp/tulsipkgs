# sonicPackages: SonicDE

[SonicDE](https://github.com/Sonic-DE) is a fork of KDE Plasma 6 that keeps X11. TulsiOS
offers it as a desktop (TulsiOS ADR 0020). This scope is the whole Sonic stack:
frameworks, Plasma and apps.

## How it is built

- `default.nix` is `kdePackagesKDE.overrideScope`. Each Sonic fork keeps nixpkgs' KDE
  recipe (`pkgs/kde`) and takes Sonic's source from `sources.json`.
- Projects Sonic has not forked or tagged use KDE's tarball of the same release
  (Frameworks 6.31.0, Plasma 6.8.2), so each layer is one release.
- Recipes of its own: `kwin.nix` (sonic-win, KWin's X11 build), `silver.nix`,
  `kgamma.nix`, `sonic-logging.nix`, `sonic-ipc.nix` (`mk-sonic-derivation.nix`).
- Adjustments to the KDE recipes are commented in `default.nix`:
  - Sonic's forks get SonicLogging, SonicIpc and QtDeclarative, and lose the Wayland-only dependencies;
  - ECM gets the QML import-path patch;
  - Breeze and plasma-integration are Qt 6 only;
  - patches for files Sonic removed are dropped;
  - a few inputs Sonic needs are added.

`all-packages.nix`: `kdePackages` is `kdePackagesKDE`; `sonicPackages` is built from it.
The KDE scope splices by the name `kdePackagesKDE`.

## Updating

    python3 pkgs/sonic/update.py

It reads sonicde-builder's package configuration (Sonic repository → KDE upstream), picks
Sonic's newest release tags (frameworks 6.N.0.x, Plasma, apps), and writes
`sources.json` with hashes. Then build the session and the apps:

    nix build .#sonicPackages.{kwin,plasma-workspace,plasma-desktop,dolphin,konsole,spectacle}

and run TulsiOS's `checks.sonic-desktop`. A fork that changed past nixpkgs' recipe
(moved files, new dependencies) needs an adjustment in `default.nix`.

## Sonic's names

These programs and D-Bus objects are renamed:

| KDE | SonicDE |
| --- | --- |
| `kwin_x11` | `sonic-win` |
| `plasmashell` (`org.kde.plasmashell` `/PlasmaShell`) | `sonicshell` (`org.sonicde.sonicshell` `/SonicShell`) |
| `spectacle` | `sonic-screenies` |

The attribute names stay KDE's (`kwin`, `plasma-workspace`, `spectacle`, …).

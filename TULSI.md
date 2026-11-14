# tulsipkgs

**tulsipkgs** is the package collection of [TulsiOS](https://github.com/lukskrp/TulsiOS):
a hard fork of [nixpkgs](https://github.com/NixOS/nixpkgs) that ships TulsiOS's own
software (Ocimum Desktop, GTK3-O, …) and an opinionated app suite.

## Branches

| Branch | What it is |
|---|---|
| `master` | Untouched mirror of upstream nixpkgs `master` |
| **`tulsi-unstable`** | **The TulsiOS distribution branch** and the repository's default branch: upstream `nixos-unstable` + TulsiOS commits. TulsiOS systems use this. |

`tulsi-sync` merges upstream `nixos-unstable` into `tulsi-unstable` every day. The merge is
pushed only if the TulsiOS packages still build and, compared with upstream, only the files
TulsiOS changes differ. Conflicts open an issue. `tulsi-unstable` must stay the default
branch: GitHub runs scheduled workflows only from the default branch.

Merge with full history (`git clone --filter=blob:none` keeps it small). In a shallow clone
git cannot see the real merge base and reports conflicts in files TulsiOS never touched.

## The rule that keeps the fork affordable

Every package whose derivation is identical to upstream is still downloaded from
cache.nixos.org. A change to a package means rebuilding it **and everything that depends
on it**, on our own CI, cached at `https://cache.skarptech.org/tulsi`. So:

1. **Stay close to upstream.** Merge `nixos-unstable` daily; don't let the branch drift.
2. **Add, don't edit.** New TulsiOS packages go in `pkgs/by-name/` (registered
   automatically, no shared file touched). Edit upstream files only for packages TulsiOS
   really forks, and only for leaf packages with few dependents (the Cinnamon suite).
3. **Never edit widely-used base packages in-tree** (`gtk3`, `glib`, `glibc`, `systemd`, `mesa`, …).
   Changing one rebuilds thousands of packages, including Firefox, LibreOffice and Chromium,
   which our CI cannot afford. Ship a separate attribute instead and graft it (as `gtk3-o`
   does) or rebuild only a curated set against it (the plan for OTK).

CI checks rule 3: `ci/tulsi/check-upstream.sh` fails if any of the curated suite would
have to be built.

## TulsiOS changes in this tree

| Path | Change |
|---|---|
| `pkgs/by-name/ci/cinnamon/package.nix` | Source → [ocimum-desktop](https://github.com/lukskrp/ocimum-desktop) branch `ocimum` (Ocimum Desktop) |
| `pkgs/by-name/gt/gtk3-o/` | GTK3-O (grafted system-wide by TulsiOS, never replaces `gtk3`) |
| `pkgs/by-name/xl/xlibre-xserver/` | [XLibre](https://github.com/X11Libre/xserver), the X server, and the table of XLibre's `xf86-*` driver forks (`drivers.nix`) |
| `pkgs/top-level/tulsi-overrides.nix`, 2 lines in `pkgs/top-level/stage.nix` | Packages replaced in place: `xorg-server` = XLibre (Xorg 21.1 stays as `xorg-server-xorg`, used by `tigervnc` and `xvfb`), every `xf86-*` driver = its XLibre fork |
| `pkgs/by-name/ot/otk/` | [OTK](https://github.com/lukskrp/OTK), the ABI-breaking GTK 3 fork (side by side with `gtk3`), with OSK (`libosk-3`, GTK 4's rendering engine) |
| `pkgs/top-level/tulsi-release.nix` | What CI builds (`built`) and what must stay upstream (`curated`) |
| `.github/workflows/tulsi-*.yml`, `ci/tulsi/` | Build + cache, daily upstream sync, AI agent fast track |
| Agent packages listed in `ci/tulsi/agents.txt` (only while a `tulsi-agents:` update is ahead of nixpkgs) | Newer vendor releases of free AI agent CLIs, by their own nixpkgs update scripts; tulsi-sync takes upstream's files once nixpkgs bumps them |
| `TULSI.md` | This file |

Keep this table up to date: it is the list of files a sync conflict can touch.

## AI agent fast track

`tulsi-agents.yml` runs every 6 hours. For each attribute in `ci/tulsi/agents.txt` (free
licences only) it:
1. runs the package's own update script (`ci/tulsi/agent-update.sh`);
2. builds the new version and checks that `--version` and `--help` work;
3. opens or refreshes one pull request per agent (branch `tulsi-agents/<attr>`).

Merging is the human step: read the changelog first. tulsi-build then caches the new
version on cache.skarptech.org.

When nixpkgs later bumps the same package, tulsi-sync resolves the conflict by taking
upstream's files. A human is needed only when an update script or build breaks, or a
licence changes. To add an agent, add its attribute to `agents.txt`. It must have
`passthru.updateScript` and a free licence.

## Common tasks

**Build what CI builds**: `nix-build pkgs/top-level/tulsi-release.nix -A built`

**Update Ocimum Desktop**: push to `ocimum-desktop`'s `ocimum` branch, then update `rev` and
`hash` in `pkgs/by-name/ci/cinnamon/package.nix`
(`nix flake prefetch github:lukskrp/ocimum-desktop/<rev>` prints the hash).

**Update XLibre or a driver**: XLibre's `version`/`hash` are in
`pkgs/by-name/xl/xlibre-xserver/package.nix`, the drivers' in `drivers.nix` there (newest
`xlibre-<name>-<version>` tag of `github.com/X11Libre/<name>`; `nix flake prefetch
github:X11Libre/<name>/<tag>` prints the hash). A new XLibre major version changes the driver
ABI: update all drivers with it. nixpkgs' own `xorg-server` and `xf86-*` files stay
untouched, so upstream changes to them merge without conflicts.

**Upstream sync conflict**:
```sh
git fetch https://github.com/NixOS/nixpkgs.git nixos-unstable
git checkout tulsi-unstable && git merge FETCH_HEAD
# resolve: keep the TulsiOS change, adapt it to upstream's new version
nix-build pkgs/top-level/tulsi-release.nix -A built
git push origin tulsi-unstable
```

## CI secrets and variables

| Name | Kind | Value |
|---|---|---|
| `ATTIC_ENDPOINT` | secret | `https://cache.skarptech.org/` |
| `ATTIC_TOKEN` | secret | push token from the cache server (`/srv/attic/ci-token`) |
| `SYNC_TOKEN` | secret | fine-grained PAT for this repo: Contents + Workflows read/write |
| `TULSI_CACHE_PUBLIC_KEY` | variable | the cache's public key, `tulsi:…` |

nixpkgs' own workflows are disabled on this fork; only `tulsi-*` workflows run.

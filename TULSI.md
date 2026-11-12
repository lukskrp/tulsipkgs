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
| `pkgs/top-level/tulsi-release.nix` | What CI builds (`built`) and what must stay upstream (`curated`) |
| `.github/workflows/tulsi-*.yml`, `ci/tulsi/` | Build + cache, daily upstream sync |
| `TULSI.md` | This file |

Keep this table up to date: it is the list of files a sync conflict can touch.

## Common tasks

**Build what CI builds**: `nix-build pkgs/top-level/tulsi-release.nix -A built`

**Update Ocimum Desktop**: push to `ocimum-desktop`'s `ocimum` branch, then update `rev` and
`hash` in `pkgs/by-name/ci/cinnamon/package.nix`
(`nix flake prefetch github:lukskrp/ocimum-desktop/<rev>` prints the hash).

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

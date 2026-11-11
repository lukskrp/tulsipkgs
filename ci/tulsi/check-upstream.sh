#!/usr/bin/env bash
# Fails if any curated package depends on something TulsiOS builds itself
# (pkgs/top-level/tulsi-release.nix `built`). Such a package would have to be
# rebuilt by TulsiOS instead of downloaded from cache.nixos.org, which means the
# fork diverged somewhere expensive. Checks the derivation graph only: nothing
# is built or downloaded, and the result does not depend on the local store.
set -euo pipefail
release=pkgs/top-level/tulsi-release.nix
name() { sed 's|.*/[a-z0-9]\{32\}-||; s|\.drv$||'; }

# Command substitution (not process substitution) so an evaluation error fails the check.
built_drvs=$(nix-instantiate "$release" -A built)
curated_drvs=$(nix-instantiate "$release" -A curated)
mapfile -t ours <<<"$built_drvs"
mapfile -t curated <<<"$curated_drvs"
if [ -z "$built_drvs" ] || [ -z "$curated_drvs" ]; then
  echo "ERROR: $release evaluated to an empty set" >&2
  exit 1
fi
echo "Checking ${#curated[@]} curated packages against ${#ours[@]} TulsiOS-built ones."

failed=0
for drv in "${curated[@]}"; do
  hits=$(nix-store -q --requisites "$drv" | grep -vxF "$drv" | grep -xF -f <(printf '%s\n' "${ours[@]}") || true)
  if [ -n "$hits" ]; then
    echo "ERROR: $(name <<<"$drv") depends on TulsiOS-built $(name <<<"$hits" | paste -sd, -)"
    failed=1
  fi
done
if [ "$failed" -ne 0 ]; then
  echo "Move these to 'built' in $release if that is intended, or undo the change that causes it."
  exit 1
fi
echo "OK: the curated suite does not depend on anything TulsiOS rebuilds."

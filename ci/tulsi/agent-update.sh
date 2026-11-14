#!/usr/bin/env bash
# ci/tulsi/agent-update.sh ATTR
#
# Fast-track one AI agent CLI (ci/tulsi/agents.txt): run its own nixpkgs update script
# (passthru.updateScript, usually nix-update, which asks the vendor's release channel
# for the newest version and recomputes every hash), then build it and smoke-test it.
#
# Leaves the change in the working tree and prints, on the last line, one of:
#   up-to-date <version>
#   updated <old> <new>
# Exits non-zero if the update script, the build or the smoke test fails.
set -euo pipefail

attr=${1:?usage: agent-update.sh ATTR}
cd "$(git rev-parse --show-toplevel)"

version() { nix-instantiate --eval --raw -A "$attr.version" .; }

old=$(version)
echo "::group::$attr $old: running its update script"
nix-shell maintainers/scripts/update.nix \
  --argstr package "$attr" \
  --argstr skip-prompt true
echo "::endgroup::"
new=$(version)

if [ "$old" = "$new" ] && git diff --quiet; then
  echo "up-to-date $old"
  exit 0
fi
if [ "$old" = "$new" ]; then
  # Same version, but the script touched files (e.g. a hash correction): keep it.
  echo "::warning::$attr stays at $new but its update script changed files"
fi

echo "::group::$attr $new: build"
out=$(nix-build -A "$attr" --no-out-link)
echo "::endgroup::"

echo "::group::$attr $new: smoke test"
exe=$(nix-instantiate --eval --raw -E "(import ./. {}).lib.getExe (import ./. {}).$attr")
home=$(mktemp -d)
# A fresh HOME, no network credentials: the CLI must start and know its version.
HOME=$home XDG_CONFIG_HOME=$home/.config NO_COLOR=1 \
  timeout 60 "$exe" --version </dev/null | tee "$home/version.txt"
grep -qF "$new" "$home/version.txt" || {
  echo "::error::$attr --version does not print $new"
  exit 1
}
HOME=$home XDG_CONFIG_HOME=$home/.config NO_COLOR=1 \
  timeout 60 "$exe" --help </dev/null >/dev/null
echo "::endgroup::"
echo "$attr $new built at $out"

echo "updated $old $new"

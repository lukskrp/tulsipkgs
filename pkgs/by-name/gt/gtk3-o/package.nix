# GTK3-O: the Ocimum fork of GTK 3.24, ABI-compatible by policy (TulsiOS ADR 0006).
#
# Only `src` is replaced. Name and version stay identical to gtk3 so the store
# path has the same length, which `system.replaceDependencies` needs to graft
# GTK3-O into a system without rebuilding its applications. Do NOT replace
# `gtk3` itself in-tree: that would invalidate the binary cache for thousands
# of packages.
{
  lib,
  gtk3,
  fetchFromGitHub,
  runCommand,
  binutils,
}:

let
  gtk3-o = gtk3.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "lukskrp";
      repo = "GTK3-24-Fork-Imprv"; # to be renamed GTK3-O
      rev = "8723146fca06edd5584d0a9e16668356af6ce308";
      hash = "sha256-Q3NH7qMO7oLiJrWKu6JcG5IwAIaL8OCEQ1wH48ICR04=";
    };
    passthru = old.passthru // {
      inherit abiCheck;
    };
    meta = old.meta // {
      description = "GTK3-O, the Ocimum fork of GTK 3 (ABI-compatible with GTK 3.24)";
      homepage = "https://github.com/lukskrp/GTK3-24-Fork-Imprv";
    };
  });

  # Fails if GTK3-O stops exporting a symbol that stock GTK 3 exports.
  abiCheck =
    runCommand "gtk3-o-abi-check"
      {
        nativeBuildInputs = [ binutils ];
        stock = gtk3;
        ours = gtk3-o;
      }
      ''
        symbols() { nm -D --defined-only "$1" | awk '{ print $NF }' | sort -u; }
        status=0
        for lib in libgtk-3.so.0 libgdk-3.so.0 libgailutil-3.so.0; do
          symbols "$stock/lib/$lib" > stock.txt
          symbols "$ours/lib/$lib" > ours.txt
          comm -23 stock.txt ours.txt > removed.txt
          comm -13 stock.txt ours.txt > added.txt
          echo "$lib: $(wc -l < stock.txt) stock symbols, $(wc -l < added.txt) added, $(wc -l < removed.txt) removed"
          if [ -s removed.txt ]; then
            echo "ERROR: GTK3-O removes exported symbols from $lib (ABI break):"
            sed 's/^/  /' removed.txt
            status=1
          fi
        done
        [ "$status" -eq 0 ] && touch "$out"
        exit "$status"
      '';
in
assert lib.assertMsg (gtk3-o.name == gtk3.name) "gtk3-o must keep gtk3's name for grafting";
gtk3-o

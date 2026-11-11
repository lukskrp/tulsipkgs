# OTK, the Ocimum Toolkit: TulsiOS's ABI-breaking fork of GTK 3.24
# (github.com/lukskrp/OTK). It installs side by side with GTK 3 under its own
# names (libotk-3, otk-3.0.pc, Otk-3.0 typelib, lib/otk-3.0 modules), so stock
# GTK 3 applications never load it; only applications built against OTK do.
# The build recipe is nixpkgs' gtk3 with OTK's names.
{
  lib,
  gtk3,
  replaceVars,
  fetchFromGitHub,
  shared-mime-info,
}:

let
  base = gtk3.override { broadwaySupport = false; };
  gtk3Dir = ../../gt/gtk3;
in
base.overrideAttrs (
  finalAttrs: old: {
    pname = "otk";
    version = "3.24.52-otk.1";

    src = fetchFromGitHub {
      owner = "lukskrp";
      repo = "OTK";
      rev = "55da1a7b70d5c2c754a4360cdda39aca3be6db1d";
      hash = "sha256-cnhZ7JRXsCWMrvFqQffx5yhIf+K67VY0yblLQ9ceeRI=";
    };

    # OTK carries its own NixOS input-method lookup (etc/otk-3.0), so the
    # gtk3 patch that points at GTK 3's cache must not be applied.
    patches = lib.filter (p: !(lib.hasSuffix "3.0-immodules.cache.patch" (toString p))) old.patches;

    # No API docs, demos or man pages: their install paths are GTK 3's.
    outputs = [
      "out"
      "dev"
    ];
    mesonFlags =
      (lib.filter (f: !(lib.hasPrefix "-Dgtk_doc=" f)) old.mesonFlags)
      ++ [
        "-Dgtk_doc=false"
        "-Ddemos=false"
        "-Dexamples=false"
        "-Dman=false"
      ];

    setupHooks = [
      (gtk3Dir + "/hooks/drop-icon-theme-cache.sh")
      (replaceVars (gtk3Dir + "/hooks/clean-immodules-cache.sh") {
        gtk_module_path = "otk-3.0";
        gtk_binary_version = "3.0.0";
      })
    ];

    postInstall = ''
      moveToOutput bin/otk-update-icon-cache "$out"
      moveToOutput bin/otk-launch "$out"
      wrapProgram $dev/bin/otk-encode-symbolic-svg --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
      GTK_PATH="''${out:?}/lib/otk-3.0/3.0.0/immodules/" ''${dev:?}/bin/otk-query-immodules-3.0 \
        > "''${out:?}/lib/otk-3.0/3.0.0/immodules.cache"
      # The header names the query tool in $dev, which would make out depend on dev.
      sed -i '/^# Created by /d' "''${out:?}/lib/otk-3.0/3.0.0/immodules.cache"
      # Key themes and gettext ITS rules are identical to GTK 3's and come from it.
      rm -r "$out/share/themes" "$out/share/gettext"
    '';
    postFixup = "";

    passthru = old.passthru // {
      updateScript = null;
    };

    meta = old.meta // {
      description = "OTK, the Ocimum Toolkit: an ABI-breaking fork of GTK 3 that installs alongside it";
      homepage = "https://github.com/lukskrp/OTK";
      pkgConfigModules = [
        "otk-3.0"
        "odk-3.0"
        "otk-x11-3.0"
        "odk-x11-3.0"
        "otk-wayland-3.0"
        "odk-wayland-3.0"
        "otk-unix-print-3.0"
        "otk-gail-3.0"
      ];
    };
  }
)

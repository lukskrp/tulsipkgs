# OTK, the Ocimum Toolkit: TulsiOS's ABI-breaking fork of GTK 3.24
# (github.com/lukskrp/OTK). It installs side by side with GTK 3 under its own
# names (libotk-3, otk-3.0.pc, Otk-3.0 typelib, lib/otk-3.0 modules), so stock
# GTK 3 applications never load it; only applications built against OTK do.
# The build recipe is nixpkgs' gtk3 with OTK's names.
#
# OSK, the Ocimum Scene Kit (libosk-3, osk-3.0, Osk-3.0), is built with it: GTK 4's
# rendering engine as an OTK module, with GtkSnapshot (OTK.md). Its tests (GTK 4's GSK
# tests, Cairo renderer, including the GtkSnapshot replay variant) need no display and
# run in the build.
#
# OTK 2 (otk.4) broke the ABI: GtkWidgetClass gained `snapshot`, so libotk-3 is .so.1
# and OTK_RENDERER=legacy|cairo selects how windows are painted.
{
  lib,
  gtk3,
  graphene,
  harfbuzz,
  libjpeg,
  libpng,
  libtiff,
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
    version = "3.24.52-otk.4";

    src = fetchFromGitHub {
      owner = "lukskrp";
      repo = "OTK";
      rev = "055d2eaffcd17737fabfaae86e457fe9c27b9bcc";
      hash = "sha256-lT7QUmWsugLtNyc8fCrzQWHfzZZnMPB7NKT+LrHzRvc=";
    };

    # OTK carries its own NixOS input-method lookup (etc/otk-3.0), so the
    # gtk3 patch that points at GTK 3's cache must not be applied.
    patches = lib.filter (p: !(lib.hasSuffix "3.0-immodules.cache.patch" (toString p))) old.patches;

    # No API docs, demos or man pages: their install paths are GTK 3's.
    outputs = [
      "out"
      "dev"
    ];
    buildInputs = old.buildInputs ++ [
      harfbuzz
      libjpeg
      libpng
      libtiff
    ];

    # Otk-3.0's introspection data includes Osk-3.0, which includes Graphene-1.0, and
    # osk-3.0.pc requires graphene-gobject-1.0; so every OTK user needs graphene, and
    # wrapGAppsHook puts its typelib on GI_TYPELIB_PATH for Python OTK apps.
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ graphene ];

    mesonFlags =
      (lib.filter (f: !(lib.hasPrefix "-Dgtk_doc=" f)) old.mesonFlags)
      ++ [
        "-Dosk=enabled"
        "-Dosk_tests=true"
        "-Dgtk_doc=false"
        "-Ddemos=false"
        "-Dexamples=false"
        "-Dman=false"
      ];

    # GTK 3's own tests need X11 and are off (-Dtests=false); OSK's run headless.
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      meson test --suite osk --no-suite failing --print-errorlogs --num-processes $NIX_BUILD_CORES
      runHook postCheck
    '';

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
        "osk-3.0"
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

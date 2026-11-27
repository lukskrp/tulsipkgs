{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  glib,
  wrapGAppsHook3,
  gtkmm3,
  cairomm_1_0,
  gdk-pixbuf,
  libarchive,
  pugixml,
  zlib,
  xvfb-run,
  hicolor-icon-theme,
  gtk3,
  gsettings-desktop-schemas,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "lunduke-paint";
  version = "1.1.0-unstable-2026-11-25";

  src = fetchFromGitHub {
    owner = "BryanLunduke";
    repo = "lunduke-paint";
    rev = "02021bd5e15a277f6eba38a0546373011d90dea1";
    hash = "sha256-gWgPGbLEPg9zWHKzuR1CBJav3bMs8gggeosEgD3IABk=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib # glib-compile-resources
    wrapGAppsHook3
  ];

  buildInputs = [
    gtkmm3
    cairomm_1_0
    gdk-pixbuf
    libarchive
    pugixml
    zlib
  ];

  # The widget tests skip (exit 77) without a display; give them one, and make a
  # missing one a failure, as upstream's packaging script does.
  doCheck = true;
  nativeCheckInputs = [
    xvfb-run
    hicolor-icon-theme
  ];
  checkPhase = ''
    runHook preCheck
    export HOME=$TMPDIR LUNDUKEPAINT_REQUIRE_DISPLAY=1
    # The Save As tests open GTK's file chooser, which needs its settings schemas.
    export XDG_DATA_DIRS=${gtk3}/share/gsettings-schemas/${gtk3.name}:${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}
    xvfb-run -s '-screen 0 1920x1080x24' meson test --print-errorlogs
    runHook postCheck
  '';

  # Upstream supports X11 only; main.cpp sets GDK_BACKEND=x11 itself.

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Layered bitmap paint program for Linux X11 (GTK 3)";
    homepage = "https://github.com/BryanLunduke/lunduke-paint";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "lunduke-paint";
  };
}

{
  fetchFromGitHub,
  cinnamon-desktop,
  cinnamon-translations,
  colord,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  lcms2,
  libcanberra-gtk3,
  libnotify,
  wrapGAppsHook3,
  pkg-config,
  lib,
  stdenv,
  systemdLibs,
  upower,
  cups,
  polkit,
  librsvg,
  libwacom,
  libxi,
  libxext,
  libx11,
  fontconfig,
  tzdata,
  nss,
  libgudev,
  meson,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cinnamon-settings-daemon";
  # TulsiOS: Ocimum's patches on top of Cinnamon's release.
  version = "6.8.1-ocimum.1";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "cinnamon-settings-daemon";
    tag = "6.8.1";
    hash = "sha256-F+Fr9nRfvUstW3K99yhKvdTng6K7xXYCFHWQ7tzzYZs=";
  };

  patches = [
    # Ocimum (TulsiOS ADR 0043): per-display brightness and gamma in the colour
    # plugin's gamma ramp (display-adjustments), and pausing the night light
    # (night-light-paused-until).
    ./ocimum-gamma.patch
  ];

  buildInputs = [
    cinnamon-desktop
    colord
    gtk3
    glib
    gsettings-desktop-schemas
    lcms2
    libcanberra-gtk3
    libnotify
    systemdLibs
    upower
    cups
    polkit
    librsvg
    libwacom
    libxext
    libx11
    libxi
    fontconfig
    nss
    libgudev
  ];

  nativeBuildInputs = [
    meson
    ninja
    wrapGAppsHook3
    pkg-config
  ];

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    sed "s|/usr/share/zoneinfo|${tzdata}/share/zoneinfo|g" -i plugins/datetime/system-timezone.h
  '';

  # use locales from cinnamon-translations (not using --localedir because datadir is used)
  postInstall = ''
    ln -s ${cinnamon-translations}/share/locale $out/share/locale
  '';

  meta = {
    homepage = "https://github.com/linuxmint/cinnamon-settings-daemon";
    description = "Settings daemon for the Cinnamon desktop";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})

{
  fetchFromGitHub,
  cinnamon-desktop,
  cinnamon-settings-daemon,
  cinnamon-translations,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  libcanberra,
  libxslt,
  meson,
  ninja,
  pkg-config,
  python3,
  lib,
  stdenv,
  systemdLibs,
  wrapGAppsHook3,
  xapp,
  libxtst,
  libxrender,
  libxext,
  libxcomposite,
  libxau,
  libx11,
  xtrans,
  libexecinfo,
  pango,
}:

let
  pythonEnv = python3.withPackages (
    pp: with pp; [
      python-xapp
      pygobject3
      setproctitle
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cinnamon-session";
  version = "6.8.0";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "cinnamon-session";
    tag = finalAttrs.version;
    hash = "sha256-DAJpmnWRYSJNUQ6S5jxQM5IrnbdImVQ/CR5UAAOcQG4=";
  };

  buildInputs = [
    # meson.build
    cinnamon-desktop
    gtk3
    glib
    libcanberra
    pango
    libx11
    libxext
    xapp
    libxau
    libxcomposite

    systemdLibs

    libxtst
    libxrender
    xtrans

    # other (not meson.build)
    cinnamon-settings-daemon
    gsettings-desktop-schemas
    pythonEnv # for cinnamon-session-quit
  ];

  nativeBuildInputs = [
    meson
    ninja
    # cinnamon-session-quit is Python + PyGObject (Gtk, XApp): gobject-introspection's
    # setup hook collects the typelibs of buildInputs into GI_TYPELIB_PATH, which
    # wrapGAppsHook3 then puts in the wrapper. Without it: "Namespace Gtk not available".
    gobject-introspection
    wrapGAppsHook3
    libexecinfo
    python3
    pkg-config
    libxslt
  ];

  # Systemd user units go in this package; the NixOS cinnamon module adds it to systemd.packages.
  env.PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  mesonFlags = [
    # use locales from cinnamon-translations
    "--localedir=${cinnamon-translations}/share/locale"
  ];

  postPatch = ''
    # patchShebangs requires executable file
    chmod +x data/meson_install_schemas.py
    patchShebangs data/meson_install_schemas.py
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${cinnamon-desktop}/share"
      --prefix XDG_CONFIG_DIRS : "${cinnamon-settings-daemon}/etc/xdg"
    )
  '';

  meta = {
    homepage = "https://github.com/linuxmint/cinnamon-session";
    description = "Cinnamon session manager";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})

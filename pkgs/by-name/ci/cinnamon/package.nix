{
  atk,
  cacert,
  dbus,
  cinnamon-control-center,
  cinnamon-desktop,
  cinnamon-menus,
  cinnamon-session,
  cinnamon-translations,
  cjs,
  evolution-data-server,
  fetchFromGitHub,
  gcr_3,
  gdk-pixbuf,
  gettext,
  libgnomekbd,
  glib,
  gobject-introspection,
  gsound,
  gtk3,
  ibus,
  json-glib,
  libsecret,
  libstartup_notification,
  libxtst,
  libxdamage,
  libgbm,
  muffin,
  networkmanager,
  pkg-config,
  polkit,
  lib,
  stdenv,
  pam,
  xdotool,
  otk,
  wrapGAppsHook3,
  libxml2,
  gtk-doc,
  python3,
  keybinder3,
  cairo,
  xapp,
  upower,
  nemo,
  libnotify,
  accountsservice,
  gnome-online-accounts,
  glib-networking,
  graphene,
  pciutils,
  timezonemap,
  libnma,
  meson,
  ninja,
  gst_all_1,
  perl,
}:

let
  pythonEnv = python3.withPackages (
    pp: with pp; [
      setproctitle
      pygobject3
      pycairo
      python-xapp
      pillow
      pyinotify # for looking-glass
      pytz
      tinycss2
      python-pam
      pexpect
      distro
      requests
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cinnamon";
  # TulsiOS: Ocimum Desktop, a hard fork of Cinnamon 6.8 (branch "ocimum", see its OCIMUM.md).
  version = "6.8.0-ocimum.2";

  src = fetchFromGitHub {
    owner = "lukskrp";
    repo = "ocimum-desktop";
    rev = "5a15b7bb85a628222e5a92697fb6b324e8e7dbcf";
    hash = "sha256-MgEwmaOXz86SCLD7Ki32w3ImNjV3A+LYzyV1H8OPIQc=";
  };

  patches = [
    ./use-sane-install-dir.patch
    ./libdir.patch
  ];

  buildInputs = [

    pam
    xdotool
    # The 6.8 background daemon (per-monitor wallpapers) is built with OTK; the shell is GTK 3.
    otk
    atk
    cacert
    cinnamon-control-center
    cinnamon-desktop
    cinnamon-menus
    cjs
    dbus
    evolution-data-server # for calendar-server
    gcr_3
    gdk-pixbuf
    glib
    graphene
    gsound
    gtk3
    ibus
    json-glib
    libsecret
    libstartup_notification
    libxtst
    libxdamage
    libgbm
    muffin
    networkmanager
    polkit
    pythonEnv
    libxml2
    libgnomekbd
    gst_all_1.gstreamer

    # bindings
    cairo
    keybinder3
    upower
    xapp
    timezonemap
    nemo
    libnotify
    accountsservice
    libnma

    # gsi bindings
    gnome-online-accounts
    glib-networking # for goa
  ];

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    wrapGAppsHook3
    gtk-doc
    perl
    python3.pkgs.libsass # for pysassc
    python3.pkgs.wrapPython
    pkg-config
  ];

  # Ocimum is X11-only (XLibre).
  mesonFlags = [ "-Dwayland=false" ];

  # Systemd user units go in this package; the NixOS cinnamon module adds it to systemd.packages.
  env.PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  postPatch = ''
    # Not meson.build: since 6.8 it names source paths like files/usr/share/cinnamon/….
    find . -type f ! -name meson.build -exec sed -i \
      -e s,/usr/share/cinnamon,$out/share/cinnamon,g \
      -e s,/usr/share/locale,/run/current-system/sw/share/locale,g \
      {} +

    # All optional and may introduce circular dependency.
    find ./files/usr/share/cinnamon/applets -type f -exec sed -i \
      -e '/^#/!s,/usr/bin,/run/current-system/sw/bin,g' \
      {} +

    pushd ./files/usr/share/cinnamon/cinnamon-settings
      substituteInPlace ./bin/capi.py                     --replace-fail '"/usr/lib"' '"${cinnamon-control-center}/lib"'
      substituteInPlace ./bin/SettingsWidgets.py          --replace-fail "/usr/share/sounds" "/run/current-system/sw/share/sounds"
      substituteInPlace ./bin/Spices.py                   --replace-fail "subprocess.run(['/usr/bin/" "subprocess.run(['"
      substituteInPlace ./modules/cs_info.py              --replace-fail "lspci" "${pciutils}/bin/lspci"
      substituteInPlace ./modules/cs_themes.py            --replace-fail "$out/share/cinnamon/styles.d" "/run/current-system/sw/share/cinnamon/styles.d"
      substituteInPlace ./modules/cs_user.py              --replace-fail "/usr/bin/passwd" "/run/wrappers/bin/passwd"
    popd

    substituteInPlace ./files/usr/bin/cinnamon-xlet-makepot \
      --replace-fail '["msgfmt",' '["${gettext}/bin/msgfmt",'

    substituteInPlace ./files/usr/bin/cinnamon-session-cinnamon \
      --replace-fail "exec cinnamon-session" "exec ${cinnamon-session}/bin/cinnamon-session"

    patchShebangs src/data-to-c.pl
  '';

  postInstall = ''
    # Use locales from cinnamon-translations.
    ln -s ${cinnamon-translations}/share/locale $out/share/locale
  '';

  preFixup = ''
    buildPythonPath "$out ${python3.pkgs.python-xapp}"

    # https://github.com/NixOS/nixpkgs/issues/200397
    patchPythonScript $out/bin/cinnamon-spice-updater

    # https://github.com/NixOS/nixpkgs/issues/129946
    patchPythonScript $out/share/cinnamon/cinnamon-desktop-editor/cinnamon-desktop-editor.py

    # Called as `pkexec cinnamon-settings-users.py`.
    wrapGApp $out/share/cinnamon/cinnamon-settings-users/cinnamon-settings-users.py
  '';

  passthru = {
    providedSessions = [ "cinnamon" ];
  };

  meta = {
    homepage = "https://github.com/linuxmint/cinnamon";
    description = "Cinnamon desktop environment";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})

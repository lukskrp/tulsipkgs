{
  lib,
  stdenv,
  fetchFromGitHub,
  xapp,
  xapp-symbolic-icons,
  gettext,
  glib,
  gobject-introspection,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "webapp-manager";
  version = "1.4.9";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "webapp-manager";
    tag = "master.mint27";
    hash = "sha256-Y8KiYl767ID1AX5GZZcy+Jl5NJQpkbZG7EKAaPUW6XQ=";
  };

  postPatch = ''
    # Brave Origin first: the first browser found is the one new web apps use.
    sed -i '/"Brave Origin", "brave-origin"/d' usr/lib/webapp-manager/common.py
    substituteInPlace usr/lib/webapp-manager/common.py \
      --replace-fail 'return [Browser(BROWSER_TYPE_FIREFOX, "Firefox", "firefox", "/usr/bin/firefox"),' \
        'return [Browser(BROWSER_TYPE_CHROMIUM, "Brave Origin", "brave-origin", "/usr/bin/brave-origin"),
                Browser(BROWSER_TYPE_FIREFOX, "Firefox", "firefox", "/usr/bin/firefox"),'

    # Browsers are found in the system profile, not /usr/bin.
    substituteInPlace usr/lib/webapp-manager/common.py \
      --replace-quiet '"/usr/bin/' '"/run/current-system/sw/bin/'

    for f in usr/lib/webapp-manager/common.py usr/lib/webapp-manager/webapp-manager.py; do
      substituteInPlace $f \
        --replace-quiet /usr/share/webapp-manager $out/share/webapp-manager \
        --replace-quiet /usr/share/locale $out/share/locale
    done
    substituteInPlace usr/bin/webapp-manager \
      --replace-fail /usr/lib/webapp-manager/webapp-manager.py $out/lib/webapp-manager/webapp-manager.py

    # Shown on every desktop, KDE ones (SonicDE) included.
    sed -i '/^NotShowIn=/d' usr/share/applications/webapp-manager.desktop
    rm -r usr/share/applications/kde4
  '';

  nativeBuildInputs = [
    gettext
    glib
    gobject-introspection
    python3.pkgs.wrapPython
    wrapGAppsHook3
  ];

  dontWrapGApps = true;

  buildInputs = [
    xapp
    python3 # for patchShebangs
  ];

  pythonPath = with python3.pkgs; [
    beautifulsoup4
    configobj
    pillow
    pycairo
    pygobject3
    python-xapp
    requests
    setproctitle
    tldextract
  ];

  buildPhase = ''
    runHook preBuild
    make buildmo
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out
    cp -r etc $out/etc
    glib-compile-schemas $out/share/glib-2.0/schemas

    runHook postInstall
  '';

  preFixup = ''
    buildPythonPath "$out ''${pythonPath[*]}"
    patchPythonScript $out/lib/webapp-manager/webapp-manager.py

    wrapProgram $out/bin/webapp-manager \
      --prefix PYTHONPATH : "$program_PYTHONPATH:$out/lib/webapp-manager" \
      --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" [ xapp-symbolic-icons ]}" \
      ''${gappsWrapperArgs[@]}
  '';

  meta = {
    description = "Run websites as if they were apps";
    homepage = "https://github.com/linuxmint/webapp-manager";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "webapp-manager";
  };
})

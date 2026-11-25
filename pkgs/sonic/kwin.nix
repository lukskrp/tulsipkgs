# sonic-win: SonicDE's X11 window manager and compositor, a fork of KWin's X11
# build (`kwin_x11`; KDE's Plasma 6.8 KWin is Wayland only). Based on the last
# nixpkgs kwin-x11 expression (NixOS 25.11).
{
  mkKdeDerivation,
  pkg-config,
  python3,
  qt5compat,
  qtsensors,
  qttools,
  libcanberra,
  libdisplay-info,
  libdrm,
  libepoxy,
  libgbm,
  lcms2,
  libxkbcommon,
  hwdata,
  libx11,
  libxi,
  libxcb,
  libxcb-util,
  libxcb-cursor,
  libxcb-image,
  libxcb-keysyms,
  libxcb-wm,
  libxcvt,
  sonic-logging,
  sonic-ipc,
  silver,
}:
mkKdeDerivation {
  pname = "kwin";

  patches = [
    ./kwin-unwrap-executable-name.patch
  ];

  # The patch adds nixos_utils.h; the service lookup then uses it, so programs
  # started through Nix's wrappers (.foo-wrapped) find their .desktop files.
  postPatch = ''
    patchShebangs src/plugins/strip-effect-metadata.py
    substituteInPlace src/utils/serviceutils.h       --replace-fail '#include <KApplicationTrader>' '#include <KApplicationTrader>
    #include "nixos_utils.h"'       --replace-fail 'fetchProcessServiceField(const QString &executablePath, const QString &fieldName)
    {' 'fetchProcessServiceField(const QString &in_executablePath, const QString &fieldName)
    {
        const QString executablePath = unwrapExecutablePath(in_executablePath);'
  '';

  # The Wayland pieces KDE's KWin needs; this X11 build does not.
  excludeDependencies = [
    "kwayland"
    "plasma-wayland-protocols"
    "wayland"
    "wayland-protocols"
  ];

  extraNativeBuildInputs = [
    pkg-config
    python3
  ];

  extraBuildInputs = [
    qt5compat
    qtsensors
    qttools

    libcanberra
    libdisplay-info
    libdrm
    libepoxy
    libgbm
    lcms2
    libxkbcommon
    hwdata

    libx11
    libxi
    libxcb
    libxcb-util
    libxcb-cursor
    libxcb-image
    libxcb-keysyms
    libxcb-wm
    libxcvt

    sonic-logging
    sonic-ipc
    silver
  ];

  # plugin QML relies on non-global imports
  dontQmlLint = true;
}

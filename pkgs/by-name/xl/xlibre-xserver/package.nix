# XLibre, the X server of TulsiOS (https://github.com/X11Libre/xserver): a fork of
# xorg-server. In tulsipkgs it is `xorg-server` itself (pkgs/top-level/all-packages.nix,
# "TulsiOS: XLibre"); Xorg 21.1 stays available as `xorg-server-xorg`.
#
# XLibre has its own driver ABI (video 28, input 26, extensions 11; Xorg 21.1 has 25, 24,
# 10), so drivers built for Xorg do not load. The xf86-* attributes are XLibre's driver
# forks (./xlibre-drivers.nix). The proprietary NVIDIA driver is detected and loaded.
#
# The recipe follows nixpkgs' xorg-server (Linux only: XQuartz stays Xorg's).
{
  lib,
  stdenv,
  fetchFromGitHub,

  # build system
  meson,
  ninja,
  pkg-config,

  # deps
  dbus,
  dri-pkgconfig-stub,
  font-util,
  libbsd,
  libdrm,
  libepoxy,
  libgbm,
  libGL,
  libGLU,
  libpciaccess,
  libtirpc,
  libunwind,
  libx11,
  libxau,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  libxcvt,
  libxdmcp,
  libxext,
  libxfixes,
  libxfont_2,
  libxkbfile,
  libxshmfence,
  mesa-gl-headers,
  openssl,
  pixman,
  systemdLibs,
  udev,
  xkbcomp,
  xkeyboard-config,
  xorgproto,
  xtrans,
  zlib,

  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xlibre-xserver";
  version = "25.1.11";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "X11Libre";
    repo = "xserver";
    tag = "xlibre-xserver-${finalAttrs.version}";
    hash = "sha256-WiI5pijPPMfW+857knrla6QX2yH8KY1m3Up2D0ssmgQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    dri-pkgconfig-stub
    font-util
    libbsd
    libdrm
    libgbm
    libtirpc
    libx11
    libxau
    libxcb
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-util
    libxcb-wm
    libxcvt
    libxdmcp
    libxfixes
    libxkbfile
    mesa-gl-headers
    openssl
    systemdLibs
    xorgproto
    xtrans
  ];

  propagatedBuildInputs = [
    dbus
    libepoxy
    libGL
    libGLU
    libpciaccess
    libunwind
    libxext
    libxfont_2
    libxshmfence
    pixman
    udev
    xorgproto
    zlib
  ];

  mesonFlags = [
    "-Dxephyr=true"
    "-Dxvfb=true"
    "-Dxnest=true"
    "-Dxorg=true"

    "-Dlog_dir=/var/log"
    "-Ddefault_font_path="

    "-Dxkb_bin_dir=${xkbcomp}/bin"
    "-Dxkb_dir=${xkeyboard-config}/share/X11/xkb"
    "-Dxkb_output_dir=$out/share/X11/xkb/compiled"

    "-Dxcsecurity=true"

    # XLibre defaults: logind integration off, seatd auto. TulsiOS sessions use logind.
    "-Dsystemd_logind=true"
    "-Dseatd_libseat=false"
    "-Ddocs=false"
    "-Ddevel-docs=false"
    "-Dtests=false"
  ];

  passthru = {
    inherit (finalAttrs) version; # needed by virtualbox guest additions
    # Where this server and its drivers keep their modules (meson's module_dir plus the
    # ABI tag). The loader searches <ModulePath>/xlibre-<major>/ first, then the
    # unversioned directories, so NixOS's ModulePath "<pkg>/lib/xorg/modules" finds
    # both XLibre drivers and Xorg-layout modules (NVIDIA's).
    moduleDir = "lib/xorg/modules/xlibre-${lib.versions.major finalAttrs.version}";
    # Module ABI versions (hw/xfree86/common/xf86Module.h); drivers must match.
    abi = {
      videodrv = 28;
      xinput = 26;
      extension = 11;
    };
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  __structuredAttrs = true;

  meta = {
    description = "XLibre X server, a fork of the X.org server";
    homepage = "https://github.com/X11Libre/xserver";
    changelog = "https://github.com/X11Libre/xserver/releases/tag/xlibre-xserver-${finalAttrs.version}";
    # Same files and licenses as xorg-server (see its package for the line ranges).
    license = with lib.licenses; [
      mit
      x11
      hpndSellVariant
      mitOpenGroup
      hpnd
      dec3Clause
      x11NoPermitPersons
      sgi-b-20
      bsd3
      adobeDisplayPostScript
      ntp
      hpndUc
      isc
      icu
      hpndSellVariantMitDisclaimerXserver
    ];
    mainProgram = "X";
    pkgConfigModules = [
      "xorg-server"
      "xlibre-server"
    ];
    platforms = lib.platforms.linux;
  };
})

# Silver: SonicDE's visual style and window decoration (a fork of Klassy).
{
  lib,
  mkSonicDerivation,
  qtsvg,
  qtdeclarative,
  frameworkintegration,
  kcmutils,
  kcoreaddons,
  kcolorscheme,
  kconfig,
  kguiaddons,
  ki18n,
  kiconthemes,
  kirigami,
  kwindowsystem,
  kdecoration,
  sonic-logging,
}:
mkSonicDerivation {
  pname = "silver";
  extraBuildInputs = [
    qtsvg
    qtdeclarative
    frameworkintegration
    kcmutils
    kcoreaddons
    kcolorscheme
    kconfig
    kguiaddons
    ki18n
    kiconthemes
    kirigami
    kwindowsystem
    kdecoration
    sonic-logging
  ];
  # The Qt 5 style is not built: SonicDE is Qt 6 only.
  extraCmakeFlags = [ "-DBUILD_QT5=OFF" ];
  meta = {
    description = "SonicDE's Silver visual style and window decoration";
    license = lib.licenses.gpl2Plus;
  };
}

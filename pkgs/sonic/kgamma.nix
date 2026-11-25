# KGamma (sonic-gamma): display gamma settings for X11, a System Settings module.
{
  lib,
  mkSonicDerivation,
  kconfig,
  kconfigwidgets,
  ki18n,
  kcmutils,
  kdoctools,
  libxxf86vm,
}:
mkSonicDerivation {
  pname = "kgamma";
  extraNativeBuildInputs = [ kdoctools ];
  extraBuildInputs = [
    kconfig
    kconfigwidgets
    ki18n
    kcmutils
    libxxf86vm
  ];
  meta = {
    description = "Gamma display settings for X11 in SonicDE's System Settings";
    license = lib.licenses.gpl2Plus;
  };
}

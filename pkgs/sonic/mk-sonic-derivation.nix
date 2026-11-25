# Projects of SonicDE's own, with no KDE counterpart (so no KDE metadata for
# mkKdeDerivation): a CMake + ECM + Qt 6 build of the scope's source `pname`.
{
  lib,
  stdenv,
  cmake,
  ninja,
  extra-cmake-modules,
  qtbase,
  wrapQtAppsHook,
  sources,
}:
{
  pname,
  src ? sources.${pname},
  version ? src.version,
  extraNativeBuildInputs ? [ ],
  extraBuildInputs ? [ ],
  extraPropagatedBuildInputs ? [ ],
  extraCmakeFlags ? [ ],
  meta ? { },
  ...
}@args:
stdenv.mkDerivation (
  removeAttrs args [
    "extraNativeBuildInputs"
    "extraBuildInputs"
    "extraPropagatedBuildInputs"
    "extraCmakeFlags"
    "meta"
  ]
  // {
    inherit pname version src;
    nativeBuildInputs = [
      cmake
      ninja
      wrapQtAppsHook
    ]
    ++ extraNativeBuildInputs;
    # ECM as a build input, as mkKdeDerivation has it: CMake finds packages there.
    buildInputs = [
      extra-cmake-modules
      qtbase
    ]
    ++ extraBuildInputs;
    propagatedBuildInputs = extraPropagatedBuildInputs;
    cmakeFlags = [
      "-DBUILD_TESTING=OFF"
      "-DQT_MAJOR_VERSION=6"
    ]
    ++ extraCmakeFlags;
    strictDeps = true;
    env.LANG = "C.UTF-8";
    meta = {
      homepage = "https://github.com/Sonic-DE/${src.repo or pname}";
      platforms = lib.platforms.linux;
    }
    // meta;
  }
)

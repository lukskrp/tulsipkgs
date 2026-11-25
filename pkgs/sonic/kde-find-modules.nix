# Sonic's ECM dropped KDE's Wayland find modules (and FindDesktopFileUtils). KDE
# apps Sonic has not forked (Gwenview, …) still find_package() them. This gives
# CMake a <Name>Config.cmake for each, on the prefix path, that loads KDE's own
# find module, so those apps configure on Sonic's ECM without changing it (which
# would rebuild the whole stack).
{
  lib,
  runCommand,
  kdeEcm,
}:
let
  modules = [
    "Wayland"
    "WaylandProtocols"
    "WaylandScanner"
    "QtWaylandScanner"
    "DesktopFileUtils"
  ];
in
runCommand "sonic-kde-find-modules" { } (
  lib.concatMapStrings (m: ''
    mkdir -p $out/lib/cmake/${m}
    echo 'include("${kdeEcm}/share/ECM/find-modules/Find${m}.cmake")' > $out/lib/cmake/${m}/${m}Config.cmake
  '') modules
)

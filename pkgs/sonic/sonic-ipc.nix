# SonicDE's IPC library (sonic-frameworks-ipc): sonic-win, the panel, the lock
# screen and the terminal talk through it.
{
  lib,
  mkSonicDerivation,
  sonic-logging,
}:
mkSonicDerivation {
  pname = "sonic-ipc";
  extraPropagatedBuildInputs = [ sonic-logging ];
  meta = {
    description = "A small inter-process communication library for SonicDE";
    license = lib.licenses.lgpl21Plus;
  };
}

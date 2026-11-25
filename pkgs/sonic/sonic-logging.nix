# SonicDE's logging library (sonic-frameworks-logging), used across its desktop.
{ lib, mkSonicDerivation }:
mkSonicDerivation {
  pname = "sonic-logging";
  meta = {
    description = "System logging library for SonicDE";
    license = lib.licenses.lgpl21Plus;
  };
}

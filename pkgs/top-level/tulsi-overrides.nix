# TulsiOS: packages that tulsipkgs replaces in place (see TULSI.md). Applied by
# pkgs/top-level/stage.nix right after all-packages.nix, so `super` holds nixpkgs'
# own definitions (including pkgs/by-name) and `self` is the final package set.
#
# Keep this small: every package changed here, and everything depending on it, is
# rebuilt by TulsiOS's CI instead of coming from cache.nixos.org.
{ lib }:
self: super:

{
  # XLibre is the X server (pkgs/by-name/xl/xlibre-xserver). Xorg 21.1 stays available
  # as xorg-server-xorg for the packages that build Xorg's own sources.
  xorg-server = self.xlibre-xserver;
  xorg-server-xorg = super.xorg-server;
  tigervnc = super.tigervnc.override { xorg-server = self.xorg-server-xorg; };
  # Xvfb builds from Xorg's tarball and takes only `meta` from xorg-server; keep it
  # Xorg's, so the many packages that test under xvfb-run are not rebuilt.
  xvfb = super.xvfb.override { xorg-server = self.xorg-server-xorg; };
}
# XLibre's driver forks for every xf86-* package
// import ../by-name/xl/xlibre-xserver/xlibre-drivers.nix {
  inherit lib;
  inherit (self) fetchFromGitHub xlibre-xserver;
} super

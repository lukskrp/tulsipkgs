# What tulsipkgs builds and distributes (CI: .github/workflows/tulsi-build.yml).
#
#   nix-build pkgs/top-level/tulsi-release.nix -A built     # what TulsiOS changes
#   nix-build pkgs/top-level/tulsi-release.nix -A curated   # TulsiOS's app suite
#
# `built` is pushed to https://cache.skarptech.org/tulsi. `curated` must not
# depend on anything in `built`: CI fails if a curated package would have to be
# rebuilt because of a TulsiOS change, since that means the fork diverged
# somewhere expensive. (Packages upstream simply has not cached are listed,
# not failed.)
{
  nixpkgs ? ../..,
  system ? builtins.currentSystem,
}:

let
  pkgs = import nixpkgs { inherit system; };
  inherit (pkgs) lib;
in
{
  built = {
    # Ocimum Desktop and the Cinnamon 6.8 suite it needs (nixpkgs ships 6.6)
    inherit (pkgs)
      cinnamon
      cinnamon-gsettings-overrides
      cinnamon-screensaver
      muffin
      cinnamon-desktop
      cinnamon-menus
      cinnamon-session
      cinnamon-settings-daemon
      cinnamon-control-center
      cinnamon-translations
      nemo
      xapp
      xdg-desktop-portal-xapp
      ;
    # GTK3-O and its ABI guard
    inherit (pkgs) gtk3-o;
    gtk3-o-abi = pkgs.gtk3-o.abiCheck;
    # OTK, the ABI-breaking toolkit that installs alongside GTK 3
    inherit (pkgs) otk;
  };

  curated = lib.recurseIntoAttrs {
    # Parts of the Cinnamon desktop taken unchanged from upstream
    inherit (pkgs)
      cjs
      mint-themes
      mint-y-icons
      ;
    # TulsiOS's opinionated app suite
    inherit (pkgs)
      firefox
      thunderbird
      libreoffice
      gimp
      vlc
      git
      htop
      ;
  };
}

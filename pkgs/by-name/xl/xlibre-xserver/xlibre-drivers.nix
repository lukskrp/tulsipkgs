# The xf86-* drivers of tulsipkgs: XLibre's forks (github.com/X11Libre/xf86-*), built
# against XLibre (`xorg-server` in tulsipkgs). XLibre has its own driver ABI, so Xorg's
# driver releases would not load.
#
# Each driver is nixpkgs' own package (pkgs/by-name/xf/<name>/package.nix, unchanged),
# given the source and version of its XLibre fork from ./drivers.nix. Applied by
# pkgs/top-level/tulsi-overrides.nix; `super` is the package set before it.
{
  lib,
  fetchFromGitHub,
  xlibre-xserver,
}:
super:

let
  inherit (xlibre-xserver) moduleDir;
in
lib.mapAttrs (
  name: d:
  super.${name}.overrideAttrs (old: {
    inherit (d) version;
    src = fetchFromGitHub {
      owner = "X11Libre";
      repo = name;
      inherit (d) tag hash;
    };
    patches = d.patches or old.patches or [ ];
    # The forks install into xorg-server.pc's `moduledir`, which is the server's own
    # store path; install into the same per-ABI layout in the driver's output instead
    # (XLibre's loader looks in <ModulePath>/xlibre-<major>/ first). Meson builds
    # ignore configureFlags; those with a module-dir option set `mesonModuleDir`, and
    # drivers that install to a fixed make variable name it in `installDirVar`.
    configureFlags = (old.configureFlags or [ ]) ++ [
      "--with-xorg-module-dir=${placeholder "out"}/${moduleDir}"
    ];
    mesonFlags =
      (old.mesonFlags or [ ])
      ++ lib.optional (d.mesonModuleDir or false) "-Dxorg-module-dir=${placeholder "out"}/${moduleDir}";
    installFlags =
      (old.installFlags or [ ])
      ++ lib.optionals (d ? installDirVar) [
        "${d.installDirVar}=${placeholder "out"}/${moduleDir}/drivers"
        # these drivers take their man page directory from the server as well
        "drvmandir=${placeholder "out"}/share/man/man4"
      ];
    # `serverM4`: configure.ac uses xorg-server.m4's macros (XORG_DRIVER_CHECK_EXT),
    # which aclocal finds only among the build tools.
    nativeBuildInputs =
      (old.nativeBuildInputs or [ ]) ++ lib.optional (d.serverM4 or false) xlibre-xserver.dev;
    passthru = (old.passthru or { }) // {
      # nixpkgs' update scripts follow freedesktop's tags; ./drivers.nix is updated by hand
      updateScript = null;
      xlibreFork = true;
    };
    meta = (old.meta or { }) // {
      homepage = "https://github.com/X11Libre/${name}";
      changelog = "https://github.com/X11Libre/${name}/releases/tag/${d.tag}";
    };
  })
) (import ./drivers.nix)

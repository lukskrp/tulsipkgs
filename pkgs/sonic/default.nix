# sonicPackages: SonicDE (https://github.com/Sonic-DE), the KDE Plasma 6 fork that
# keeps X11, as a scope over kdePackages.
#
# Each Sonic fork keeps tulsipkgs' KDE expression (dependencies, patches,
# wrapping) and takes Sonic's tagged source from sources.json (update.py), by
# swapping the scope's `sources`: Sonic's frameworks (its desktop uses API only
# they have), Plasma and apps. Projects Sonic has not forked are pinned to KDE's
# tarball of the same Frameworks or Plasma release, so each layer is one release.
{
  lib,
  kdePackages,
  fetchurl,
  fetchzip,
  ffmpeg,
  libpulseaudio,
  libei,
  replaceVars,
  fontconfig,
  lsof,
  xmessage,
  aha,
  clinfo,
  dmidecode,
  iproute2,
  libdisplay-info,
  lm_sensors,
  mesa-demos,
  pciutils,
  pulseaudio,
  util-linux,
  vulkan-tools,
  xdpyinfo,
}:

let
  sonicSources = lib.mapAttrs (
    _: v:
    (
      if v.unpack then
        fetchzip {
          inherit (v) url hash;
        }
      else
        fetchurl {
          inherit (v) url hash;
        }
    )
    // {
      inherit (v) version;
      repo = v.repo or null;
    }
  ) (lib.importJSON ./sources.json);
in
kdePackages.overrideScope (
  final: prev:
  let
    # Sonic's forks use its logging library throughout (find_package(SonicLogging)).
    sonicForks = lib.filterAttrs (
      name: v:
      v.unpack
      && prev ? ${name}
      && !(builtins.elem name [
        "extra-cmake-modules"
        "kwin"
      ])
    ) (lib.importJSON ./sources.json);
    # KDE's dependency metadata is for its Wayland Plasma; Sonic's X11 forks do
    # without these (and Sonic's ECM no longer finds Wayland protocols), and
    # without the mobile and media-center shells' plasma-nano.
    waylandOnly = [
      "plasma-nano"
      "layer-shell-qt"
      "kwayland"
      "plasma-wayland-protocols"
      "wayland"
      "wayland-protocols"
    ];
    # (KDE's dependency lists hold nulls for test-only stubs, e.g. selenium-webdriver-at-spi.)
    notWaylandOnly = dep: dep != null && !(builtins.elem (lib.getName dep) waylandOnly);
    withSonicLogging = lib.mapAttrs (
      name: _:
      prev.${name}.overrideAttrs (old: {
        # Sonic's CMake configs ask for Qt's QML integration, and its own libraries.
        propagatedBuildInputs = builtins.filter notWaylandOnly (old.propagatedBuildInputs or [ ]) ++ [
          final.sonic-logging
          final.sonic-ipc
          final.qtdeclarative
        ];
        buildInputs = builtins.filter notWaylandOnly (old.buildInputs or [ ]);
      })
    ) sonicForks;
  in
  withSonicLogging
  // {
    sources = prev.sources // sonicSources;

    mkSonicDerivation = final.callPackage ./mk-sonic-derivation.nix { };

    # SonicDE's own libraries, used across its desktop.
    sonic-logging = final.callPackage ./sonic-logging.nix { };
    sonic-ipc = final.callPackage ./sonic-ipc.nix { };

    # Sonic's ECM 6.31 predates KDE's search of the QML import path (6.32).
    extra-cmake-modules = prev.extra-cmake-modules.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./ecm-qml-import-path.patch ];
    });

    kde-find-modules = final.callPackage ./kde-find-modules.nix {
      kdeEcm = kdePackages.extra-cmake-modules;
    };
  }
  # KDE apps (not Sonic forks) that ask for the find modules Sonic's ECM dropped.
  // lib.genAttrs [ "gwenview" "kdeconnect-kde" ] (
    name:
    prev.${name}.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ final.kde-find-modules ];
    })
  )
  // {

    kdecoration = withSonicLogging.kdecoration.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ final.qtdeclarative ];
    });

    # Sonic's Breeze is Qt 6 only: no Qt 5 style to build or move to its own output.
    breeze = withSonicLogging.breeze.overrideAttrs {
      outputs = [
        "out"
        "dev"
      ];
      cmakeFlags = [
        "-DQT_MAJOR_VERSION=6"
        "-DBUILD_QT5=OFF"
      ];
      postInstall = "";
    };

    # Qt 6 only too: no Qt 5 platform theme to move to its own output.
    plasma-integration = withSonicLogging.plasma-integration.overrideAttrs {
      outputs = [
        "out"
        "dev"
      ];
      cmakeFlags = [
        "-DQT_MAJOR_VERSION=6"
        "-DBUILD_QT5=OFF"
      ];
      postInstall = "";
    };

    # Silver GTK themes the GTK side like Silver (find_package(SonicSilver)).
    breeze-gtk = withSonicLogging.breeze-gtk.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ final.silver ];
    });

    # Screenies records the screen through FFmpeg (X11), not PipeWire.
    spectacle = withSonicLogging.spectacle.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [
        ffmpeg
        libpulseaudio
      ];
    });

    # The panel talks to sonic-win (SonicWinDwellClickerIpc); Sonic already
    # dropped Discover from the task manager, which nixpkgs patches out for KDE.
    plasma-desktop = withSonicLogging.plasma-desktop.overrideAttrs (old: {
      # (The wallpaper patch is for KDE's SDDM theme, which Sonic's plasma-desktop lacks.)
      patches = builtins.filter (
        p:
        !(lib.hasSuffix "no-discover-shortcut.patch" (toString p))
        && !(lib.hasSuffix "wallpaper-paths.patch" (toString p))
      ) (old.patches or [ ]);
      buildInputs = (old.buildInputs or [ ]) ++ [ final.kwin ];
    });

    # Sonic's portal emulates input through libei.
    xdg-desktop-portal-kde = withSonicLogging.xdg-desktop-portal-kde.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ libei ];
    });

    # nixpkgs' tool paths for the information pages, without the Wayland page's.
    kinfocenter = withSonicLogging.kinfocenter.overrideAttrs {
      patches = [
        (replaceVars ./kinfocenter-tool-paths.patch {
          QtBinariesDir = null;
          aha = lib.getExe aha;
          clinfo = lib.getExe clinfo;
          di_edid_decode = lib.getExe libdisplay-info;
          dmidecode = lib.getExe' dmidecode "dmidecode";
          eglinfo = lib.getExe' mesa-demos "eglinfo";
          glxinfo = lib.getExe' mesa-demos "glxinfo";
          ip = lib.getExe' iproute2 "ip";
          lsblk = lib.getExe' util-linux "lsblk";
          lspci = lib.getExe' pciutils "lspci";
          lscpu = lib.getExe' util-linux "lscpu";
          pactl = lib.getExe' pulseaudio "pactl";
          qdbus = lib.getExe' final.qttools "qdbus";
          sensors = lib.getExe' lm_sensors "sensors";
          vulkaninfo = lib.getExe' vulkan-tools "vulkaninfo";
          xdpyinfo = lib.getExe xdpyinfo;
        })
      ];
    };

    # Sonic's QMK keyboard support is a C++ D-Bus helper, not KDE's Rust one.
    kdeplasma-addons = withSonicLogging.kdeplasma-addons.overrideAttrs (old: {
      cargoRoot = null;
      cargoDeps = null;
      nativeBuildInputs = builtins.filter (
        d:
        !(lib.hasPrefix "cargo-setup-hook" (lib.getName d))
        && !(builtins.elem (lib.getName d) [
          "rustc"
          "cargo"
        ])
      ) old.nativeBuildInputs;
    });

    # Sonic Terminal's QML settings use KDeclarative's org.kde.kquickcontrols.
    konsole = withSonicLogging.konsole.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ final.kdeclarative ];
    });

    # sonic-win: KWin's X11 window manager and compositor (KDE's Plasma 6.8 KWin
    # is Wayland only).
    kwin = final.callPackage ./kwin.nix { };

    # Sonic's own style and window decoration (a Klassy fork) and its X11 gamma tool.
    silver = final.callPackage ./silver.nix { };
    kgamma = final.callPackage ./kgamma.nix { };

    # The X11 session (sonicde.desktop) instead of KDE's Wayland one.
    plasma-workspace = withSonicLogging.plasma-workspace.overrideAttrs (old: {
      # nixpkgs' store paths for the tools it runs, without the hunk for KDE's
      # Wayland-only plasma-setup-xwayland (which Sonic does not have).
      patches = [
        (replaceVars ./plasma-workspace-dependency-paths.patch {
          fcMatch = lib.getExe' fontconfig "fc-match";
          lsof = lib.getExe lsof;
          qdbus = lib.getExe' final.qttools "qdbus";
          xmessage = lib.getExe xmessage;
          QtBinariesDir = null;
        })
      ];
      # The splash screen by its store path (the patch's hunk for it does not fit Sonic).
      postPatch = (old.postPatch or "") + ''
        substituteInPlace startkde/startplasma.cpp           --replace-fail 'p->start(QStringLiteral("ksplashqml"),'                          'p->start(QStringLiteral(CMAKE_INSTALL_FULL_BINDIR "/ksplashqml"),'
      '';
      # A session unit runs qdbus from Qt's binaries directory, which is qtbase's
      # here; qdbus is in qttools.
      postFixup = (old.postFixup or "") + ''
        sed -i 's|ExecStart=[^ ]*/bin/qdbus |ExecStart=${lib.getExe' final.qttools "qdbus"} |'           $out/share/systemd/user/plasma-kcminit-phase1.service
      '';
      passthru = (old.passthru or { }) // {
        providedSessions = [ "sonicde" ];
      };
    });
  }
)

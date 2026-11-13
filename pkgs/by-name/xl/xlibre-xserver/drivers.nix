# XLibre's driver forks: version, tag and source hash for each xf86-* package.
# To update one: take the newest xlibre-<name>-<version> tag from
# https://github.com/X11Libre/<name> and run
#   nix flake prefetch github:X11Libre/<name>/<tag>
# for the hash. Optional: `patches` replaces nixpkgs' patches for that driver;
# `mesonModuleDir`, `installDirVar` and `serverM4` are explained in ./xlibre-drivers.nix.
{
  xf86-input-evdev = { version = "25.0.0"; tag = "xlibre-xf86-input-evdev-25.0.0"; hash = "sha256-Wed22W6rYm/78v8i6TBBfyUN4RdmEsOEfCr1ecBgisE="; };
  xf86-input-joystick = { version = "25.0.0"; tag = "xlibre-xf86-input-joystick-25.0.0"; hash = "sha256-PB5BU6lbEFTziXzjlQxQwVkxZDYycWsVE5tr8rLJ3GY="; };
  xf86-input-keyboard = { version = "25.0.0"; tag = "xlibre-xf86-input-keyboard-25.0.0"; hash = "sha256-c/H7qNU1bCjbKgYAIy0oXjw4WywyflADSB1gW1zeKjk="; };
  xf86-input-libinput = { version = "25.0.1"; tag = "xlibre-xf86-input-libinput-25.0.1"; hash = "sha256-dCpnup8MCmwpZp9jPGCZYnjBwu13r2o1gWm8mAw9U+A="; };
  xf86-input-mouse = { version = "25.0.0"; tag = "xlibre-xf86-input-mouse-25.0.0"; hash = "sha256-88qW8egN7dMP6HLO2LQGRAH/88w6BSErglC5QP0IPqY="; };
  xf86-input-synaptics = { version = "25.0.0"; tag = "xlibre-xf86-input-synaptics-25.0.0"; hash = "sha256-mVQJa/MNgkONbvPVQRucXebfXL5q8J0b0ftY8tLS6gM="; };
  xf86-input-vmmouse = { version = "25.0.0"; tag = "xlibre-xf86-input-vmmouse-25.0.0"; hash = "sha256-QUYw8kekgtYIIqToBO4Y5V1t0IyeJUBfk/3CVjLeNEs="; };
  xf86-input-void = { version = "25.0.0"; tag = "xlibre-xf86-input-void-25.0.0"; hash = "sha256-rjOR2GzZvuJN8iA3wGLqpbcfrCVUuhKk2qnvQNVmjsA="; };
  xf86-input-wacom = { version = "25.0.0"; tag = "xlibre-xf86-input-wacom-25.0.0"; hash = "sha256-SJAj5jZm47JrDnckSeZP7le0pBt2T9EH8jQFx+3mn0w="; };
  xf86-video-amdgpu = { version = "25.1.2"; tag = "xlibre-xf86-video-amdgpu-25.1.2"; hash = "sha256-/12/ANaXVUVZoPLDNJDzUrO4pnE309tyDTXGWoC0qr8="; };
  xf86-video-apm = { version = "25.0.0"; tag = "xlibre-xf86-video-apm-25.0.0"; hash = "sha256-keSijsb7FCTvSOEdRzV4CPXjwSgyiDSt96vtv7pxJvE="; };
  xf86-video-ark = { version = "25.0.0"; tag = "xlibre-xf86-video-ark-25.0.0"; hash = "sha256-Ubg/0Xz5uHW+/kUz82df8+FN5dJOnXye9pjyEXe4IuA="; };
  xf86-video-ast = { version = "25.0.0"; tag = "xlibre-xf86-video-ast-25.0.0"; hash = "sha256-bAGU4StGrZBwSkF0qciT0AT2vTBN39AnOpvhjGn4LzM="; };
  xf86-video-ati = { version = "25.0.1"; tag = "xlibre-xf86-video-ati-25.0.1"; hash = "sha256-PR3z/hn/k15q1Npbb9f5Ca2OfEmQx8edYbOPPKNd3hI="; };
  xf86-video-chips = { version = "25.0.0"; tag = "xlibre-xf86-video-chips-25.0.0"; hash = "sha256-9fL6Bz/GRcJA9lkCXgvnb9UoPrnxI6VA4CNhHNZUKjQ="; };
  xf86-video-cirrus = { version = "25.0.0"; tag = "xlibre-xf86-video-cirrus-25.0.0"; hash = "sha256-To6+S7qqnLjmH2thx6UZoQqHKGs46l82EC4l1Ns0ukM="; };
  xf86-video-dummy = { version = "25.0.0"; tag = "xlibre-xf86-video-dummy-25.0.0"; hash = "sha256-xzWqInzfcXhW35nEK+CVIK29/aMonHNK9LFJmqEIpgk="; };
  xf86-video-fbdev = { version = "25.0.0"; tag = "xlibre-xf86-video-fbdev-25.0.0"; hash = "sha256-b/zygUDsJDRc9n70KEtRPnHRiwuPWdiFQEojocCrTmE="; };
  xf86-video-geode = { version = "25.0.0"; tag = "xlibre-xf86-video-geode-25.0.0"; hash = "sha256-o46BfPOb0p97Fb9o0gvPmNKjnIBxVeCX3zSUi4kwt+4="; };
  xf86-video-i128 = { version = "25.0.0"; tag = "xlibre-xf86-video-i128-25.0.0"; hash = "sha256-8qgPnF8Uc9mk63YPkIb2DQ/tbd+TAXEvDoA4M8QcpqQ="; };
  xf86-video-i740 = { version = "25.0.0"; tag = "xlibre-xf86-video-i740-25.0.0"; hash = "sha256-twWmxwStKqcvglB5CJ0uGdgw23u6xhOITncVRRoWttE="; };
  xf86-video-intel = { version = "25.0.2"; tag = "xlibre-xf86-video-intel-25.0.2"; hash = "sha256-wPU4KNC1FFv3d6fwvPT/vHERwf1Ges7wCJLwRPmjFC0="; mesonModuleDir = true; };
  xf86-video-mga = { version = "25.0.0"; tag = "xlibre-xf86-video-mga-25.0.0"; hash = "sha256-74fYlRDOV2H0woTloPk4ntmN8p4CqV25BHILT0/sUUQ="; };
  xf86-video-neomagic = { version = "25.0.0"; tag = "xlibre-xf86-video-neomagic-25.0.0"; hash = "sha256-YuGEFqZXyFHUN4CCkrVHbyW4BX0mT1TwM5nw1HNQjhM="; };
  xf86-video-nested = { version = "25.0.0"; tag = "xlibre-xf86-video-nested-25.0.0"; hash = "sha256-GPmow0G6XvzoWqBHvp3JI6o682gpLPzma4vbOPi1eMg="; };
  xf86-video-nouveau = { version = "25.0.1"; tag = "xlibre-xf86-video-nouveau-25.0.1"; hash = "sha256-UOnAStqhcv1SlrDTBdyMVbSmrpn9TIiFjWcJ1xy/INg="; };
  xf86-video-nv = { version = "25.0.0"; tag = "xlibre-xf86-video-nv-25.0.0"; hash = "sha256-A2NWeknO0djqoSoP8hGu/tPMKc2NJi812VKkTISSkXo="; };
  xf86-video-omap = { version = "25.0.0"; tag = "xlibre-xf86-video-omap-25.0.0"; hash = "sha256-+JjMuguhBb7BecD/Dhw/mcNAnkHVfQYl1gXi2cwwHTk="; };
  xf86-video-openchrome = { version = "25.0.0"; tag = "xlibre-xf86-video-openchrome-25.0.0"; hash = "sha256-QPYEJsX2/UW095pakDm6d6nx1NPev9J/xwP6JiXQtRE="; serverM4 = true; };
  xf86-video-qxl = { version = "25.0.0"; tag = "xlibre-xf86-video-qxl-25.0.0"; hash = "sha256-CHqmOehS01JZAtp4pGU7j6mR2ccqI6w2TpK2hhd/XR0="; };
  xf86-video-r128 = { version = "25.0.0"; tag = "xlibre-xf86-video-r128-25.0.0"; hash = "sha256-S4Xfd83OdveAU38L+mPr6BbTJ9ko/lMrVqFb/rNmJ34="; };
  xf86-video-s3virge = { version = "25.0.0"; tag = "xlibre-xf86-video-s3virge-25.0.0"; hash = "sha256-QGhF2iUObI/GfSKrJxcv8VBG5yJsGNnaRdrrP9ha08o="; };
  xf86-video-savage = { version = "25.0.0"; tag = "xlibre-xf86-video-savage-25.0.0"; hash = "sha256-comOu7+c2NAAo2ZYUgV8hOL1JcMQppONGdEFoFOFtxU="; };
  xf86-video-siliconmotion = { version = "25.0.0"; tag = "xlibre-xf86-video-siliconmotion-25.0.0"; hash = "sha256-v5FlisIZroyJyLho8KP5YDM20zq6/IXvsLwigbTyhc8="; };
  xf86-video-sis = { version = "25.0.0"; tag = "xlibre-xf86-video-sis-25.0.0"; hash = "sha256-FWPZUriDWleX1kkFdLB8DyanjuUGtWuXZ9b37mXC14o="; };
  xf86-video-sisusb = { version = "25.0.0"; tag = "xlibre-xf86-video-sisusb-25.0.0"; hash = "sha256-Tjh/SYfs/G7moxCgScrFFVwIyxWdpBbpzEWdg+XEbWs="; };
  xf86-video-suncg6 = { version = "25.0.0"; tag = "xlibre-xf86-video-suncg6-25.0.0"; hash = "sha256-NMIGfd/RLR14pMaBmpNq1R5FrJTRWeevIgwx1ENZYkg="; };
  xf86-video-sunffb = { version = "25.0.0"; tag = "xlibre-xf86-video-sunffb-25.0.0"; hash = "sha256-NidmQqbu9vHoH4pmvEj7hzfRisVd+VCpF/FA8obmAxU="; };
  xf86-video-sunleo = { version = "25.0.0"; tag = "xlibre-xf86-video-sunleo-25.0.0"; hash = "sha256-zc73MoLlRAsGK6HWAYL5tfFpBkebEeqvDKG9PvYTRNI="; };
  xf86-video-tdfx = { version = "25.0.0"; tag = "xlibre-xf86-video-tdfx-25.0.0"; hash = "sha256-OHjj7cEYWmIHbSuBh4QHlVK5SCIDh1EwqTZTggC39DA="; };
  xf86-video-trident = { version = "25.0.0"; tag = "xlibre-xf86-video-trident-25.0.0"; hash = "sha256-5xXC/l+PL2tK28q1AiD+U/urcT98BqqFm7erjfdRrrc="; };
  xf86-video-v4l = { version = "25.0.1"; tag = "xlibre-xf86-video-v4l-25.0.1"; hash = "sha256-2pnChf8wYRZPsmkiDknehvSw82uIuKXXCgWrWn/3W+k="; installDirVar = "v4l_drv_ladir"; };
  xf86-video-vbox = { version = "25.0.0"; tag = "xlibre-xf86-video-vbox-25.0.0"; hash = "sha256-iXHSnwPdJzy/ALo3WyhLFBH2L3pKvoW2BQcnwQB8aHw="; };
  xf86-video-vesa = { version = "25.0.0"; tag = "xlibre-xf86-video-vesa-25.0.0"; hash = "sha256-SSTHl5YMp+23JCtoTb+YWAmkGKDzH3Ro3f0WHFYrbnQ="; };
  xf86-video-vmware = { version = "25.0.0"; tag = "xlibre-xf86-video-vmware-25.0.0"; hash = "sha256-tMLVEFyMFEsRyHGaxQmx46zsloDYcXp8qZ3AwGypm/w="; };
  xf86-video-voodoo = { version = "25.0.0"; tag = "xlibre-xf86-video-voodoo-25.0.0"; hash = "sha256-hmdq8m8xFMDhVVOOkZapFw2rfgTm82SqRmknBNMKgjE="; };
}

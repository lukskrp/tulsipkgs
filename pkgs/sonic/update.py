#!/usr/bin/env python3
"""Regenerate pkgs/sonic/sources.json: SonicDE's sources for the sonicPackages scope.

SonicDE (https://github.com/Sonic-DE) forks KDE Plasma 6 to keep X11. Every Sonic
repository names its KDE upstream in sonicde-builder's config; the scope takes
tulsipkgs' KDE expression for that upstream and swaps in Sonic's release tag:

- Plasma (repositories tracking upstream/Plasma/<version>), KWin (sonic-win, X11),
  Sonic's themes (sonic-breeze, sonic-silver, …) and the chosen apps;
- Plasma projects Sonic has not forked, at KDE's tarball of the same Plasma
  version, so the whole desktop is one release;
- KDE Frameworks: Sonic's forks (they add API its desktop uses, e.g. KToolsArea)
  at its newest Frameworks tag; frameworks Sonic has not forked at KDE's tarball
  of the same Frameworks release, since frameworks need siblings of one version.

usage: update.py [--builder DIR] [--offline-check]
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "sources.json")
KDE_PLASMA = os.path.join(HERE, "..", "kde", "generated", "sources", "plasma.json")
KDE_FRAMEWORKS = os.path.join(HERE, "..", "kde", "generated", "sources", "frameworks.json")
GITHUB = "https://github.com/Sonic-DE"

# Sonic repositories that are not in the builder's upstream mapping, or map to a
# name tulsipkgs does not have: repository -> attribute.
EXTRA = {
    "sonic-win": "kwin",  # the X11 KWin (its own expression, kwin.nix)
    "sonic-breeze": "breeze",
    "sonic-silver": "silver",  # Klassy fork: Sonic's own style and decoration
    "sonic-gamma": "kgamma",
    "sonic-silver-sound-theme": "ocean-sound-theme",
    "sonic-power-management": "powerdevil",
    "sonic-print-management": "print-manager",
    "sonic-keyboard": "plasma-keyboard",
    "sonic-theme-sdk": "plasma-sdk",
}

# Sonic's own libraries (no KDE counterpart) that the desktop needs, at Sonic's
# Frameworks release.
SONIC_ONLY = {
    "sonic-frameworks-logging": "sonic-logging",
    "sonic-frameworks-ipc": "sonic-ipc",
}

# Apps (KDE Gear forks) that come with the desktop.
APPS = {"sonic-ecco", "sonic-terminal", "sonic-system-monitor", "sonic-screenies"}

# Plasma projects not part of an X11 desktop; left out of the version pin.
SKIP = {"plasma-mobile", "plasma-bigscreen", "plasma-dialer", "spacebar", "plasma-nano",
        "plasma-setup", "lightdm-greeter-kde", "plasma-login-manager", "kwayland-integration",
        "breeze-grub", "breeze-plymouth", "plymouth-kcm", "discover", "flatpak-kcm", "kup",
        "union"}


def run(*cmd: str) -> str:
    return subprocess.run(cmd, check=True, capture_output=True, text=True).stdout.strip()


def mapping(builder: str) -> dict[str, tuple[str, str]]:
    """repository -> (upstream name, tracked upstream branch) from the builder's YAML."""
    d = os.path.join(builder, "config", "sonicde", "packages", "sonicde")
    out = {}
    for f in sorted(os.listdir(d)):
        if not f.endswith(".yaml"):
            continue
        text = open(os.path.join(d, f), encoding="utf-8").read()
        m = re.search(r"upstream:\s*\n\s*url:\s*(\S+)", text)
        up = os.path.basename(m.group(1)).removesuffix(".git") if m else ""
        up = re.sub(r"^\$\{\w+\}", "", up)
        t = re.search(r"autopick\.upstream:\s*(\S+)", text)
        out[f[:-5]] = (up, t.group(1) if t else "")
    return out


def version_key(tag: str) -> list[int]:
    return [int(x) for x in re.findall(r"\d+", tag)]


def latest_tag(repo: str, prefix: str) -> str | None:
    refs = run("git", "ls-remote", "--tags", "--refs", f"{GITHUB}/{repo}.git")
    tags = [line.split("refs/tags/")[1] for line in refs.splitlines()]
    tags = [t for t in tags if t == prefix or t.startswith(prefix + ".")]
    return max(tags, key=version_key) if tags else None


def sri(base32: str) -> str:
    return run("nix", "--extra-experimental-features", "nix-command", "hash", "convert",
               "--hash-algo", "sha256", "--to", "sri", base32)


def prefetch(url: str, unpack: bool) -> str:
    args = ["nix-prefetch-url", "--type", "sha256"] + (["--unpack"] if unpack else []) + [url]
    return sri(run(*args).splitlines()[-1])


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--builder", help="a sonicde-builder checkout (cloned if absent)")
    ap.add_argument("--plasma", default="6.8.2", help="SonicDE's Plasma release")
    ap.add_argument("--gear", default="26.08.3", help="SonicDE's Gear (apps) release")
    ap.add_argument("--frameworks", default="6.31.0", help="SonicDE's Frameworks release (its own libraries)")
    a = ap.parse_args()

    builder = a.builder
    if not builder:
        builder = os.path.join(tempfile.mkdtemp(), "sonicde-builder")
        run("git", "clone", "-q", "--depth", "1", f"{GITHUB}/sonicde-builder.git", builder)
    kde = json.load(open(KDE_PLASMA, encoding="utf-8"))
    kf = json.load(open(KDE_FRAMEWORKS, encoding="utf-8"))
    kf_release = ".".join(a.frameworks.split(".")[:2])  # 6.31.0 -> 6.31

    chosen: dict[str, tuple[str, str]] = {}  # attr -> (repo, tag prefix)
    for repo, (up, track) in mapping(builder).items():
        attr = EXTRA.get(repo, up)
        if attr in kf:
            chosen[attr] = (repo, a.frameworks)
        elif repo in APPS:
            chosen[attr] = (repo, a.gear if "release/" in track else a.plasma)
        elif track.startswith("upstream/Plasma/") or repo in EXTRA:
            if attr in SKIP:
                continue
            chosen[attr] = (repo, a.plasma)
    for repo, attr in EXTRA.items():
        chosen.setdefault(attr, (repo, a.plasma))
    for repo, attr in SONIC_ONLY.items():
        chosen[attr] = (repo, a.frameworks)

    sources = {}
    for attr, (repo, prefix) in sorted(chosen.items()):
        tag = latest_tag(repo, prefix)
        if tag is None:
            # Not released by Sonic at this version: KDE's own (below), if KDE has one.
            print(f"{attr:32} {repo}: no {prefix} tag, KDE's is used", file=sys.stderr)
            continue
        url = f"{GITHUB}/{repo}/archive/refs/tags/{tag}.tar.gz"
        print(f"{attr:32} {repo} {tag}", file=sys.stderr)
        sources[attr] = {"version": tag, "repo": repo, "url": url, "hash": prefetch(url, True), "unpack": True}

    # Frameworks Sonic has not forked: KDE's tarball of the same Frameworks release.
    for attr in sorted(kf):
        if attr in sources:
            continue
        url = f"mirror://kde/stable/frameworks/{kf_release}/{attr}-{a.frameworks}.tar.xz"
        https = url.replace("mirror://kde/", "https://download.kde.org/")
        print(f"{attr:32} KDE {a.frameworks}", file=sys.stderr)
        sources[attr] = {"version": a.frameworks, "url": url, "hash": prefetch(https, False), "unpack": False}

    # Plasma projects Sonic has not forked: KDE's tarball of the same release.
    for attr in sorted(kde):
        if attr in sources or attr in SKIP:
            continue
        url = f"mirror://kde/stable/plasma/{a.plasma}/{attr}-{a.plasma}.tar.xz"
        https = url.replace("mirror://kde/", "https://download.kde.org/")
        print(f"{attr:32} KDE {a.plasma}", file=sys.stderr)
        sources[attr] = {"version": a.plasma, "url": url, "hash": prefetch(https, False), "unpack": False}

    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(sources, f, indent=2, sort_keys=True)
        f.write("\n")
    print(f"wrote {len(sources)} sources to {OUT}", file=sys.stderr)


if __name__ == "__main__":
    main()

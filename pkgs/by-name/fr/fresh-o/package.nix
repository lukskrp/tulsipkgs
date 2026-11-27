{
  lib,
  rustPlatform,
  fetchFromGitHub,
  gzip,
  makeBinaryWrapper,
  pkg-config,
  openssl,
  oniguruma,
  gitMinimal,
  python3,
  versionCheckHook,
}:
# fresh-o: TulsiOS's hard fork of Fresh (sinelaw/fresh, at v0.5.9), developed on
# its own (see its FORK.md). The command is still `fresh`. fresh-editor next to it
# is nixpkgs' package of upstream Fresh, kept for merges from nixpkgs.
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fresh-o";
  version = "0.5.9-o1";

  src = fetchFromGitHub {
    owner = "lukskrp";
    repo = "fresh-o";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P8m/kX7Lma4yieOPkezz1dH5Xc5/NOw5tFEZB7xbD6Y=";
  };

  # The fork has Fresh 0.5.9's Cargo.lock.
  cargoHash = "sha256-lNCzwQpLzGTsU3qPouin1ZqUME8XgUHtTQPcCdU1TEs=";

  __structuredAttrs = true;

  nativeBuildInputs = [
    gzip
    makeBinaryWrapper
    pkg-config
  ];

  nativeCheckInputs = [
    python3
    gitMinimal
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    oniguruma
  ];

  preBuild = ''
    mkdir -p $out/share/fresh-editor/plugins/
  '';

  postInstall = ''
    # The app-menu entry (a terminal app) and the manual page.
    install -Dm644 crates/fresh-editor/resources/fresh.desktop -t $out/share/applications
    install -Dm644 crates/fresh-editor/resources/fresh.1 -t $out/share/man/man1
    install -Dm644 crates/fresh-editor/flatpak/io.github.sinelaw.fresh.svg $out/share/icons/hicolor/scalable/apps/fresh.svg
    # The update check and telemetry are off by default in fresh-o; the flag also
    # keeps a person's own config from turning them on against upstream's servers.
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
      --add-flags "--no-upgrade-check" \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
  '';

  checkFlags = [
    "--skip=e2e::"
    "--skip=services::plugins::embedded::tests::test_extract_plugins"
    # Network access.
    "--skip=services::release_checker::tests::the_release_feed_override_is_shared_by_check_and_update"
    "--skip=services::release_checker::tests::test_update_checker"
    # The build sandbox has no /bin/sh, the plugin directory isn't writable there,
    # and 0.5.9's changelog has a credit the test's parser rejects.
    "--skip=services::remote::spawner::tests::ssh_launcher_carries_multiline_values_to_the_shell"
    "--skip=services::plugins::embedded::tests::every_embedded_plugin_is_precompiled"
    "--skip=release_notes::parse::tests::the_real_changelog_parses"
  ];
  cargoTestFlags = [
    "--lib"
    "--bins"
  ];
  # Assertions are only on in debug builds.
  checkType = "debug";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # `fresh --version` prints the crate version, Fresh's base (0.5.9).
  versionCheckProgramArg = "--version";
  preVersionCheck = ''
    version=${lib.head (lib.splitString "-" finalAttrs.version)}
  '';

  meta = {
    description = "Terminal text editor: TulsiOS's hard fork of Fresh (command: fresh)";
    homepage = "https://github.com/lukskrp/fresh-o";
    changelog = "https://github.com/lukskrp/fresh-o/blob/main/FORK.md";
    license = lib.licenses.gpl3Plus;
    mainProgram = "fresh";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})

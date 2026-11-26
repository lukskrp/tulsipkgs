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
  nix-update-script,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fresh";
  version = "0.5.9";

  src = fetchFromGitHub {
    owner = "sinelaw";
    repo = "fresh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+30iF8mWxOVrm5bPHWzY9khuMf3bHOESyV5ferySoH0=";
  };

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
    install -Dm644 crates/fresh-editor/flatpak/io.github.sinelaw.fresh.svg       $out/share/icons/hicolor/scalable/apps/fresh.svg
    # --no-upgrade-check also turns off the anonymous telemetry (main.rs).
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
      --add-flags "--no-upgrade-check" \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
  '';

  # Tests create a local http server to check update functionality
  __darwinAllowLocalNetworking = true;

  # Due to issues with incorrect import paths with the actual app, I have disabled the checks below. Need to report upstream.
  checkFlags = [
    "--skip=e2e::"
    "--skip=services::plugins::embedded::tests::test_extract_plugins"
    # require network access
    "--skip=services::release_checker::tests::the_release_feed_override_is_shared_by_check_and_update"
    # flaky: https://github.com/NixOS/nixpkgs/pull/585026#issuecomment-6741147524
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
  # cfg(debug_assertions) is not set for release builds, so we need to run tests in debug mode to get the assertions enabled.
  checkType = "debug";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal based IDE & text editor: easy, powerful and fast";
    homepage = "https://getfresh.dev";
    changelog = "https://github.com/sinelaw/fresh/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      chillcicada
      dwt
      randoneering
      sinelaw
    ];
    mainProgram = "fresh";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})

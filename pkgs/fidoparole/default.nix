{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeDesktopItem,
  copyDesktopItems,
  pkg-config,
  wrapGAppsHook3,
  glib-networking,
  gtk3,
  libfido2,
  librsvg,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fidoparole";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "token2";
    repo = "fidoparole";
    tag = finalAttrs.version;
    hash = "sha256-pjAVe2jK9oUynchhWy182gl3pSKDYK88eLjoBskzkR4=";
  };

  # Tauri embeds the frontend from ../ui at compile time.
  sourceRoot = "${finalAttrs.src.name}/src-tauri";

  cargoHash = "sha256-WS3xpN9NKovQZq7hfU1vM5HzxArnR/UjW4GcWJwuzL0=";

  # custom-protocol is what `cargo tauri build` enables for release builds.
  buildFeatures = [ "tauri/custom-protocol" ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    copyDesktopItems
  ];

  # Upstream's build.sh clones libfido2 and links it statically; build.rs
  # links the system library dynamically when FIDO2_LINK_STATIC is unset.
  buildInputs = [
    glib-networking
    gtk3
    libfido2
    librsvg
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  # Upstream ships no bundle (tauri.conf.json sets bundle.active = false).
  desktopItems = [
    (makeDesktopItem {
      name = "fidoparole";
      desktopName = "FidoParole";
      comment = finalAttrs.meta.description;
      exec = "fidoparole";
      icon = "fidoparole";
      categories = [ "Utility" ];
    })
  ];

  postInstall = ''
    install -Dm644 icons/icon.png $out/share/icons/hicolor/512x512/apps/fidoparole.png
  '';

  meta = {
    description = "Password vault stored on a FIDO2 security key (hmac-secret + largeBlob)";
    homepage = "https://github.com/token2/fidoparole";
    # The repository states no license.
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "fidoparole";
  };
})

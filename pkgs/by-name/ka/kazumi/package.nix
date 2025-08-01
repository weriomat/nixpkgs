{
  lib,
  fetchFromGitHub,
  flutter332,
  webkitgtk_4_1,
  alsa-lib,
  libayatana-appindicator,
  autoPatchelfHook,
  gst_all_1,
  stdenv,
  mimalloc,
  mpv,
  mpv-unwrapped,
  runCommand,
  yq,
  kazumi,
  _experimental-update-script-combinators,
  gitUpdater,
}:

flutter332.buildFlutterApplication rec {
  pname = "kazumi";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "Predidit";
    repo = "Kazumi";
    tag = version;
    hash = "sha256-Tzg8vFu2/ZLHQ1Ijp4et+qNPX0ytTZ//zVqQHJ6QBxs=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    webkitgtk_4_1
    alsa-lib
    libayatana-appindicator
    mpv
    gst_all_1.gstreamer
    gst_all_1.gst-vaapi
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
  ];

  customSourceBuilders = {
    # unofficial media_kit_libs_linux
    media_kit_libs_linux =
      { version, src, ... }:
      stdenv.mkDerivation rec {
        pname = "media_kit_libs_linux";
        inherit version src;
        inherit (src) passthru;

        postPatch = ''
          sed -i '/set(MIMALLOC "mimalloc-/,/add_custom_target/d' libs/linux/media_kit_libs_linux/linux/CMakeLists.txt
          sed -i '/set(PLUGIN_NAME "media_kit_libs_linux_plugin")/i add_custom_target("MIMALLOC_TARGET" ALL DEPENDS ${mimalloc}/lib/mimalloc.o)' libs/linux/media_kit_libs_linux/linux/CMakeLists.txt
        '';

        installPhase = ''
          runHook preInstall

          cp -r . $out

          runHook postInstall
        '';
      };
    # unofficial media_kit_video
    media_kit_video =
      { version, src, ... }:
      stdenv.mkDerivation rec {
        pname = "media_kit_video";
        inherit version src;
        inherit (src) passthru;

        postPatch = ''
          sed -i '/set(LIBMPV_ZIP_URL/,/if(MEDIA_KIT_LIBS_AVAILABLE)/{//!d; /set(LIBMPV_ZIP_URL/d}' media_kit_video/linux/CMakeLists.txt
          sed -i '/if(MEDIA_KIT_LIBS_AVAILABLE)/i set(LIBMPV_HEADER_UNZIP_DIR "${mpv-unwrapped.dev}/include/mpv")' media_kit_video/linux/CMakeLists.txt
          sed -i '/if(MEDIA_KIT_LIBS_AVAILABLE)/i set(LIBMPV_PATH "${mpv}/lib")' media_kit_video/linux/CMakeLists.txt
          sed -i '/if(MEDIA_KIT_LIBS_AVAILABLE)/i set(LIBMPV_UNZIP_DIR "${mpv}/lib")' media_kit_video/linux/CMakeLists.txt
        '';

        installPhase = ''
          runHook preInstall

          cp -r . $out

          runHook postInstall
        '';
      };
  };

  gitHashes =
    let
      media_kit-hash = "sha256-N6QoktM8u9NYF8MAXLsxM9RlV8nICM4NbnmABHTRkZg=";
    in
    {
      desktop_webview_window = "sha256-Z9ehzDKe1W3wGa2AcZoP73hlSwydggO6DaXd9mop+cM=";
      webview_windows = "sha256-9oWTvEoFeF7djEVA3PSM72rOmOMUhV8ZYuV6+RreNzE=";
      media_kit = media_kit-hash;
      media_kit_libs_android_video = media_kit-hash;
      media_kit_libs_ios_video = media_kit-hash;
      media_kit_libs_linux = media_kit-hash;
      media_kit_libs_macos_video = media_kit-hash;
      media_kit_libs_video = media_kit-hash;
      media_kit_libs_windows_video = media_kit-hash;
      media_kit_video = media_kit-hash;
    };

  postInstall = ''
    ln -snf ${mpv}/lib/libmpv.so.2 $out/app/kazumi/lib/libmpv.so.2
    install -Dm0644 assets/linux/io.github.Predidit.Kazumi.desktop $out/share/applications/io.github.Predidit.Kazumi.desktop
    install -Dm0644 assets/images/logo/logo_linux.png $out/share/icons/hicolor/512x512/apps/io.github.Predidit.Kazumi.png
  '';

  passthru = {
    pubspecSource =
      runCommand "pubspec.lock.json"
        {
          nativeBuildInputs = [ yq ];
          inherit (kazumi) src;
        }
        ''
          cat $src/pubspec.lock | yq > $out
        '';
    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater { })
      (_experimental-update-script-combinators.copyAttrOutputToFile "kazumi.pubspecSource" ./pubspec.lock.json)
    ];
  };

  meta = {
    description = "Watch Animes online with danmaku support";
    homepage = "https://github.com/Predidit/Kazumi";
    mainProgram = "kazumi";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}

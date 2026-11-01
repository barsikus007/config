{
  lib,
  android-tools,
  fetchFromGitHub,
  fuse3,
  pkg-config,
  stdenv,
}:
#? https://github.com/spion/adbfs-rootless/issues/56
stdenv.mkDerivation (finalAttrs: {
  pname = "adbfs-rootless-libfuse-3";
  version = "0-unstable-2023-03-21";

  src = fetchFromGitHub {
    owner = "spion";
    repo = "adbfs-rootless";
    rev = "feat/merge-libfuse-3";
    hash = "sha256-FWGJyJv7c0FZ6NvepcavxWpeUT0KanU8D4B1FL7QxPI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ fuse3 ];

  postPatch = ''
    # very ugly way of replacing the adb calls
    substituteInPlace adbfs.cpp \
      --replace-fail '"adb ' '"${android-tools}/bin/adb '
  '';

  installPhase = ''
    runHook preInstall
    install -D adbfs $out/bin/adbfs
    runHook postInstall
  '';

  meta = {
    description = "Mount Android phones on Linux with adb, no root required";
    mainProgram = "adbfs";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
  };
})

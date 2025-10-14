{
  lib,
  fetchFromGitHub,
  flutter329,

  mpv,

  libplacebo,
  libdovi,
}:

flutter329.buildFlutterApplication rec {
  pname = "ShikiWatch";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "wheremyfiji";
    repo = "ShikiWatch";
    tag = "v${version}";
    hash = "sha256-b5FK5XW0iRyMMtYCnlpHht8WbVFeO26jMeDxncJ9taA=";
  };

  buildInputs = [
    mpv
  ]
  ++ mpv.unwrapped.buildInputs
  ++ libplacebo.buildInputs
  ++ [ libdovi ];

  inputsFrom = [ mpv ];

  autoPubspecLock = src + /pubspec.lock;
  # yq . pubspec.lock -o=json > ./pubspec.lock.json
  # pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = {
    dart_discord_rpc = "sha256-YYQ9BRFgq5FSLLb+AIzH1q09RKNwKuhTH2TN4MTkfhQ=";
    flutter_secure_storage_linux = "sha256-cFNHW7dAaX8BV7arwbn68GgkkBeiAgPfhMOAFSJWlyY=";
  };

  preBuild = ''
    echo "Don't work: https://github.com/wheremyfiji/ShikiWatch/issues/39"
    exit
    echo "Creating env files"
    echo "const String appBuildDateTime = '2025-09-08T13:03:00.000Z';" > lib/build_date_time.dart
    # cp lib/secret.example.dart lib/secret.dart
  '';

  meta = with lib; {
    description = "Unofficial Android and Windows application for Shikimori";
    homepage = "https://github.com/wheremyfiji/ShikiWatch";
    downloadPage = "https://github.com/wheremyfiji/ShikiWatch/releases";
    platforms = with platforms; lists.intersectLists x86_64 linux ;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ barsikus007 ];
  };
}

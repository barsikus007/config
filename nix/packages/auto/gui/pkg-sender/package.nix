{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  fontconfig,
  libGL,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  makeDesktopItem,
}:
#? also for chiaki-ng:
# python3 -c "
# import urllib.request, struct, base64
# data = urllib.request.urlopen('ftp://192.168.1.105:2121/system_data/settings/system.dat').read()
# pos = data.find(struct.pack('<I', 0x07800500))
# raw = data[pos+8:pos+16]
# print('hex (LE):', raw.hex())
# print('hex (BE):', raw[::-1].hex())
# print('base64:  ', base64.b64encode(raw[::-1]).decode())
# "
buildDotnetModule {
  pname = "pkg-sender";
  version = "1.2.8-unstable-2026-09-27";
  src = fetchFromGitHub {
    owner = "Loopayeh";
    repo = "pkg-sender";
    rev = "04b5b2183bad9d248053a378d56094537272c44b";
    hash = "sha256-ytvj+JFtxCXCibFtz0j/lqP6uvrpRRLeXvbEHSDrCCU=";
  };
  postPatch = ''
    substituteInPlace LoopDPI.Core/Ps4Installer.cs \
      --replace-fail 'if (await IsGoldHenOnlineAsync(ip)) return "goldhen";' \
                     'if (await TcpOnlyAsync(ip, 2121) == "open") return "goldhen";' \
      --replace-fail 'if (await CanConnectPayloadPortAsync(ip)) return "goldhen";' "" \
      --replace-fail 'listener.Bind(new IPEndPoint(IPAddress.Any, 0));' \
                     'try { listener.Bind(new IPEndPoint(IPAddress.Any, 9897)); } catch { listener.Bind(new IPEndPoint(IPAddress.Any, 0)); }'
  '';
  nativeBuildInputs = [ copyDesktopItems ];
  postInstall = ''
    install -D -m 644 $src/library/Assets/logo.ico $out/share/icons/hicolor/256x256/apps/pkgsender.ico || true
  '';
  desktopItems = [
    (makeDesktopItem {
      name = "pkgsender";
      categories = [
        "Utility"
        "Network"
      ];
      desktopName = "PKG Sender";
      exec = "PkgSender";
      genericName = "PS4 / PS5 Package Sender";
    })
  ];
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "PkgSender" ];
  nugetDeps = ./deps.json;
  projectFile = "library/PkgSender.csproj";
  runtimeDeps = [
    fontconfig
    libice
    libsm
    libx11
    libxrandr
    libxcursor
    libxi
    libGL
  ];
  meta = {
    description = "PS4 / PS5 PKG LAN installer with multi-piece streaming support";
    homepage = "https://github.com/Loopayeh/pkg-sender";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "PkgSender";
  };
}

{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "free-turn-proxy";
  version = "4.1.5";
  src = fetchFromGitHub {
    owner = "hackdiaz-dev";
    repo = "free-turn-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WSFNdVt/L58htENK4qYEnJsWwSNnPK1BXG4bgTjcXAo=";
  };
  vendorHash = "sha256-jLKRSoVscLgO7cyNV17x0/MH5q70PsH96UvFRVh+ZQs=";
  #? both binaries are named too generic to keep in PATH as is
  postInstall = ''
    mv $out/bin/client $out/bin/free-turn-proxy-client
    mv $out/bin/server $out/bin/free-turn-proxy-server
  '';
  #? same flags as upstream .goreleaser.yaml
  ldflags = [
    "-s"
    "-w"
    "-checklinkname=0"
    "-X"
    "main.version=${finalAttrs.version}"
  ];
  subPackages = [
    "cmd/client"
    "cmd/server"
  ];
  passthru.updateScript = nix-update-script { };
  meta = {
    description = "Proxy tunnel encapsulating UDP/TCP traffic over the TURN protocol";
    homepage = "https://github.com/hackdiaz-dev/free-turn-proxy";
    changelog = "https://github.com/hackdiaz-dev/free-turn-proxy/blob/v${finalAttrs.version}/CHANGELOG.md";
    #? MIT text plus a "you must be kind to bunnies" clause
    license = {
      free = true;
      fullName = "Happy Bunny License (HBL)";
      url = "https://github.com/hackdiaz-dev/free-turn-proxy/blob/v${finalAttrs.version}/LICENSE";
    };
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "free-turn-proxy-client";
  };
})

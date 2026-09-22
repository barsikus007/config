{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "free-turn-proxy";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "samosvalishe";
    repo = "free-turn-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tng7yb9eRSag4ByTdBNgWDPo8vaOtLhFvv4ICITSGm4=";
  };

  vendorHash = "sha256-H8ep4HsR2CEubgh6UKeR3AI56pRkObYNEojNo4ENyIg=";

  subPackages = [
    "cmd/client"
    "cmd/server"
  ];

  #? same flags as upstream .goreleaser.yaml
  ldflags = [
    "-s"
    "-w"
    "-checklinkname=0"
    "-X"
    "main.version=${finalAttrs.version}"
  ];

  #? both binaries are named too generic to keep in PATH as is
  postInstall = ''
    mv $out/bin/client $out/bin/free-turn-proxy-client
    mv $out/bin/server $out/bin/free-turn-proxy-server
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Proxy tunnel encapsulating UDP/TCP traffic over the TURN protocol";
    homepage = "https://github.com/samosvalishe/free-turn-proxy";
    changelog = "https://github.com/samosvalishe/free-turn-proxy/blob/v${finalAttrs.version}/CHANGELOG.md";
    #? MIT text plus a "you must be kind to bunnies" clause
    license = {
      fullName = "Happy Bunny License (HBL)";
      url = "https://github.com/samosvalishe/free-turn-proxy/blob/v${finalAttrs.version}/LICENSE";
      free = true;
    };
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "free-turn-proxy-client";
  };
})

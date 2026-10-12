{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "free-turn-proxy";
  version = "4.0.1";
  src = fetchFromGitHub {
    owner = "hackdiaz-dev";
    repo = "free-turn-proxy";
    # tag = "v${finalAttrs.version}";
    rev = "d0dbec3e03e805c45600a0330be848fb6a2c7f1a";
    hash = "sha256-cnMV7c1j0bV1PZsefkDkXtJoJzo+Ix3k0dqL9JuslK0=";
  };
  vendorHash = "sha256-H8ep4HsR2CEubgh6UKeR3AI56pRkObYNEojNo4ENyIg=";
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
    homepage = "https://github.com/samosvalishe/free-turn-proxy";
    changelog = "https://github.com/samosvalishe/free-turn-proxy/blob/v${finalAttrs.version}/CHANGELOG.md";
    #? MIT text plus a "you must be kind to bunnies" clause
    license = {
      free = true;
      fullName = "Happy Bunny License (HBL)";
      url = "https://github.com/samosvalishe/free-turn-proxy/blob/v${finalAttrs.version}/LICENSE";
    };
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "free-turn-proxy-client";
  };
})

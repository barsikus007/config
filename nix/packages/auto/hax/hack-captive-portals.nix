{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  gawk,
  gnugrep,
  iproute2,
  makeWrapper,
  net-tools,
  nmap,
  sipcalc,
}:

stdenv.mkDerivation {
  pname = "hack-captive-portals";
  version = "unstable-2017-01-25";

  src = fetchFromGitHub {
    owner = "crishoj";
    repo = "hack-captive-portals";
    rev = "e0374ce7c3398040bc0f9fbce6b5eefb74325344"; # Latest commit from crishoj/master
    hash = "sha256-UNYxbSwi/We1rI4fjGx8JgQQDvnr1N581BIBgbb5Vp4="; # Replace with actual hash after first build failure
  };

  nativeBuildInputs = [ makeWrapper ];

  # runtime dependencies
  buildInputs = [
    gnugrep
    gawk
    net-tools
    iproute2

    coreutils
    sipcalc
    nmap
  ];

  installPhase = ''
    runHook preInstall
    install -D --mode=755 hack-captive.sh $out/bin/hack-captive-portals
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/hack-captive-portals \
      --prefix PATH : ${
        lib.makeBinPath [
          gnugrep
          gawk
          net-tools
          iproute2

          coreutils
          sipcalc
          nmap
        ]
      }
  '';

  meta = {
    description = "Script to hack captive portals via MAC spoofing";
    homepage = "https://github.com/crishoj/hack-captive-portals";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ barsikus007 ];
    platforms = lib.platforms.linux;
    mainProgram = "hack-captive-portals";
  };
}

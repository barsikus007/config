{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,

  gnugrep,
  gawk,
  net-tools,
  iproute2,

  coreutils,
  sipcalc,
  nmap,
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

  # Runtime dependencies
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
    install -Dm755 hack-captive.sh $out/bin/hack-captive-portals
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

  meta = with lib; {
    description = "Script to hack captive portals via MAC spoofing";
    homepage = "https://github.com/crishoj/hack-captive-portals";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "hack-captive-portals";
  };
}

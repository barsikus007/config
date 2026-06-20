{
  lib,
  stdenv,
  fetchFromGitHub,
  gawk,
  makeWrapper,
  coreutils,
}:
#? https://github.com/NixOS/nixpkgs/pull/348161
stdenv.mkDerivation (finalAttrs: {
  pname = "shdotenv";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "ko1nksm";
    repo = "shdotenv";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3O9TUA3/vuC12OJTxVVoAGmgSRq+1xPG7LxX+aXqVCo=";
  };

  buildInputs = [
    gawk
    makeWrapper
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  postFixup = ''
    wrapProgram $out/bin/shdotenv \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gawk
        ]
      }
  '';

  meta = {
    description = "Dotenv for shells with support for POSIX-compliant and multiple .env file syntax";
    homepage = "https://github.com/ko1nksm/shdotenv";
    platforms = lib.platforms.all;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      hadrienmp
      barsikus007
    ];
    mainProgram = "shdotenv";
  };
})

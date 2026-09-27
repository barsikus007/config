{
  fetchFromGitHub,
  fsearch,
  itstool,
}:
let
  version = "0.3.2";
in
fsearch.overrideAttrs (previousAttrs: {
  inherit version;

  src = fetchFromGitHub {
    owner = "cboxdoerfer";
    repo = "fsearch";
    rev = version;
    hash = "sha256-IdcNjlloyJEGZ1BbGxaeLGUiDhrku9fIXM45LwQ8iRc=";
  };

  nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
    itstool
  ];
})

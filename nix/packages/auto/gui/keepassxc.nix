{
  fetchFromGitHub,
  keepassxc,
  keyutils,
  qt6Packages,
  ...
}:
let
  version = "2.8.0-beta1";
in
(keepassxc.override {
  libsForQt5 = qt6Packages;
  withKeePassX11 = false;
}).overrideAttrs
  (previousAttrs: {
    inherit version;

    src = fetchFromGitHub {
      owner = "keepassxreboot";
      repo = "keepassxc";
      rev = "v${version}";
      hash = "sha256-fksThYmGZed66zxGDxlS2SHQzJYRf+T9AuZPbaNZV5Y=";
    };

    patches = [ ];

    doCheck = false;
    checkPhase = "";

    buildInputs = previousAttrs.buildInputs ++ [ keyutils ];
  })

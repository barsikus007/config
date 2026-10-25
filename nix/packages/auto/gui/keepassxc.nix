{
  fetchFromGitHub,
  keepassxc,
  keyutils,
  qt6Packages,
  ...
}:
let
  version = "2.8.0";
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
      rev = version;
      hash = "sha256-821zL+xnCsHU8VvxsJh2a2LRGstSIq3tWQbWBk8g4hc";
    };
    patches = [ ];
    buildInputs = previousAttrs.buildInputs ++ [ keyutils ];
    doCheck = false;
    checkPhase = "";
  })

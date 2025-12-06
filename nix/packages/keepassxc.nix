{
  keepassxc,
  fetchFromGitHub,
  keyutils,
  ...
}:
(keepassxc.overrideAttrs (old: {
  version = "2.8.0-snapshot";

  src = fetchFromGitHub {
    owner = "keepassxreboot";
    rev = "967dc5937f1f69e601f7aecbc600ef9027cc5043";
    sha256 = "sha256-Nfp5B8OZ3NIZIHkR/aVwdnose61gPVEEFsRjEyUm7uw=";
    repo = "keepassxc";
  };

  cmakeFlags = old.cmakeFlags ++ [
    "-DWITH_XC_ALL=ON"
  ];

  buildInputs = old.buildInputs ++ [ keyutils ];
}))

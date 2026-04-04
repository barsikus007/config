{
  lib,
  stdenv,
  keepassxc,
  fetchFromGitHub,
  keyutils,
  fetchpatch2,
  ...
}:
#? https://github.com/hey2022/dotfiles/blob/67109c6ce326163a192059a660e87e7fa30d87cf/pkgs/keepassxc-snapshot/default.nix
(keepassxc.overrideAttrs (previousAttrs: {
  version = "2.8.0-unstable-2026-03-15";

  src = fetchFromGitHub {
    owner = "keepassxreboot";
    rev = "379be00127db60b1ddee9c67f4bfc49c15db8236";
    hash = "sha256-Lf0fNflOMYU3WSzPmia2l3urp0/s3UHZOPx5MzDUPFs=";
    repo = "keepassxc";
  };

  env =
    (lib.optionalAttrs stdenv.cc.isGNU {
      NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-enum-enum-conversion";
    })
    // previousAttrs.env;

  patches = previousAttrs.patches ++ [
    (fetchpatch2 {
      url = "https://patch-diff.githubusercontent.com/raw/keepassxreboot/keepassxc/pull/13161.patch";
      hash = "sha256-HjFuaJZwcr8JZLtdIlet7lYRWmHpoXqPg/0eC9LIjH8=";
    })
  ];

  buildInputs = previousAttrs.buildInputs ++ [ keyutils ];
}))

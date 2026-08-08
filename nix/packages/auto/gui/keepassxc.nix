{
  lib,
  stdenv,
  keepassxc,
  fetchFromGitHub,
  keyutils,
  ...
}:
#? https://github.com/hey2022/dotfiles/blob/bf5a1f7e6bc96c8950b9be7c716c1cf72aa7205a/pkgs/keepassxc-snapshot/default.nix
(keepassxc.overrideAttrs (previousAttrs: {
  version = "2.8.0-unstable-2025-04-17";
  # TODO: rename with flake update
  # version = "2.8.0-unstable-2026-04-17";

  src = fetchFromGitHub {
    owner = "keepassxreboot";
    repo = "keepassxc";
    rev = "007839bd909a373710da4a06bff414c5002e6cf0";
    hash = "sha256-lnhtnE0g+IBGEADoeIi0yeUFfVJ1zrI6OPz2LAYSpAk=";
  };

  env =
    (lib.optionalAttrs stdenv.cc.isGNU {
      NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-enum-enum-conversion";
    })
    // previousAttrs.env;

  buildInputs = previousAttrs.buildInputs ++ [ keyutils ];
}))

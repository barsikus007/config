{ pkgs, ... }:
#? pinned to a master commit, ~1900 commits ahead of the v6.7.8 tag nixpkgs ships
#? https://github.com/AyuGram/AyuGramDesktop/commit/4c23f16ab84c55b6fde47e7b32c3ccb1875b9a9b
pkgs.ayugram-desktop.overrideAttrs (wrapperAttrs: {
  unwrapped = wrapperAttrs.unwrapped.overrideAttrs (previousAttrs: {
    #! base tdesktop moved 7.0.2 -> 7.0.4 here, nixpkgs' telegram-desktop deps may lag behind
    version = "7.0.4-unstable-2026-08-05";

    src = pkgs.fetchFromGitHub {
      owner = "AyuGram";
      repo = "AyuGramDesktop";
      rev = "4c23f16ab84c55b6fde47e7b32c3ccb1875b9a9b";
      hash = "sha256-P4Ze6r4sTCMbxP2sRhjmTo1TNusvfg6oka41R687Yu4=";
      fetchSubmodules = true;
    };

    #! codegen only collects `lng_`-prefixed keys into the per-file lang subsets,
    #! so every `tr::ayu_*` is undeclared - see the patch header for details
    patches = (previousAttrs.patches or [ ]) ++ [
      ./ayugram-lang-subsets-ayu-prefix.patch
      # TODO: rename with flake update
      # ./lang-subsets-ayu-prefix.patch
    ];

    #? upstream builds changelog from `v${version}`, which is no longer a real tag
    meta = previousAttrs.meta // {
      changelog = "https://github.com/AyuGram/AyuGramDesktop/commits/4c23f16ab84c55b6fde47e7b32c3ccb1875b9a9b";
    };
  });
})

{ pkgs }:

# watch anime in terminal (cli)
# only russian sources

pkgs.python3Packages.buildPythonApplication rec {
  pname = "anicli_ru";
  version = "5.0.16";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit
      pname
      version
      ;
    hash = "sha256-gM9on15RQIpQVJfWW/uPeN63vSSbCJt2mNN5zkvc5Jg=";
  };

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs; [
    (callPackage ./anicli-api.nix {
      version = "0.7.14";
      hash = "sha256-zmB2U4jyDPCLuykUc6PyrlcTULaXDxQ8ZvyTmJfOI0s=";
    })
    (callPackage ./eggella.nix {
      version = "0.1.7";
      hash = "sha256-8Vo39BePA86wcLKs/F+u2N7tpIpPrEyEPp3POszy050=";
    })
    python3Packages.tqdm
  ];

  meta = {
    homepage = "https://github.com/vypivshiy/ani-cli-ru";
    mainProgram = "anicli-ru";
  };
}

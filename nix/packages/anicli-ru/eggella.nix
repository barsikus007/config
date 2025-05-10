{
  pkgs,
  #
  version ? null,
  hash ? null,
}:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "eggella";
  inherit version;
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit
      pname
      version
      hash
      ;
  };

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs.python3Packages; [
    prompt-toolkit
  ];
}

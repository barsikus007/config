{
  pkgs,
  #
  version ? null,
  hash ? null,
}:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "anicli_api";
  inherit version;
  pyproject = true;
  dontCheckRuntimeDeps = true;

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
    attrs
    httpx
    httpx.optional-dependencies.http2
    httpx.optional-dependencies.socks
    parsel
  ];
}

{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  openssl,
}:
let
  python3Env = python3.withPackages (
    ps: with ps; [
      pyusb
      crcmod
      python-periphery
      spidev
      pycryptodome
      crccheck
    ]
  );
in
stdenvNoCC.mkDerivation {
  pname = "goodix-fp-patch";
  version = "UwU";
  src = fetchFromGitHub {
    owner = "goodix-fp-linux-dev";
    repo = "goodix-fp-dump";
    # rev = "master";
    rev = "cc43bb3b3154a0bccc0412ae024013c7e1923139";
    hash = "sha256-AVq2PZe0iv9Mh8+XRr/vbZsbvDIrPKD90Xdu9lXs8p0=";
    fetchSubmodules = true;
  };

  patchPhase = ''
    #? comment "if len(otp) < 64:" check
    sed -i '133,134s/^/#/' driver_52xd.py
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp -r ./* "$out/"
    cat > "$out/bin/run_521d" << EOF
    #!/bin/sh
    cd "$out/"
    export PATH="$PATH:${openssl}/bin"
    ${lib.getExe python3Env} "run_521d.py"
    EOF
    chmod +x "$out/bin/run_521d"
  '';
}

{
  lib,
  applyPatches,
  cmake,
  fetchFromGitHub,
  makeWrapper,
  python3Packages,
  rustPlatform,
  vulkan-headers,
  vulkan-loader,
}:
#? pkexec $(nix build ~/config/nix#penguin-burner --no-link --print-out-paths)/bin/penguin-burnerd
#? $(nix build ~/config/nix#penguin-burner --no-link --print-out-paths)/bin/penguin-burner-cli --auto-uv-voltage-scan --auto-uv-mode efficiency --auto-uv-min-voltage-mv 625
let
  version = "0.8.3-unstable-2026-10-20";

  rawSrc = fetchFromGitHub {
    owner = "jpietek";
    repo = "PenguinBurner";
    #? PR 131: Start Q2RTX verification on rendering events
    rev = "bf312801eb284921181be2a5f811ece1f9558419";
    hash = "sha256-KfVhJLhLDNKPTq/t+IFQHqB1/pD7eqmIolbijRSoeTE=";
  };

  src = applyPatches {
    src = rawSrc;
    patches = [
      ./turing-vf-fallback.patch
    ];
  };

  inherit (python3Packages) python;

  deps = with python3Packages; [
    pyside6
    colorama
    pyqtgraph
    pyyaml
  ];

  penguin-burnerd = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "penguin-burnerd";
    nativeBuildInputs = [ makeWrapper ];
    cargoLock.lockFile = "${rawSrc}/burnerd/Cargo.lock";
    doCheck = false;
    postPatch = ''
      substituteInPlace src/scan.rs \
        --replace-fail '"LD_LIBRARY_PATH",' ""
    '';
    postInstall = ''
      wrapProgram $out/bin/penguin-burnerd \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}:/run/opengl-driver/lib \
        --run 'if [ -z "$PENGUIN_BURNER_DAEMON_ALLOWED_UID" ]; then if [ -n "$PKEXEC_UID" ]; then export PENGUIN_BURNER_DAEMON_ALLOWED_UID="$PKEXEC_UID"; elif [ -n "$SUDO_UID" ]; then export PENGUIN_BURNER_DAEMON_ALLOWED_UID="$SUDO_UID"; fi; fi' \
        --run 'if [ -z "$PENGUIN_BURNER_HOME" ]; then if [ -n "$PKEXEC_UID" ]; then export PENGUIN_BURNER_HOME="$(getent passwd "$PKEXEC_UID" | cut -d: -f6)"; elif [ -n "$SUDO_USER" ]; then export PENGUIN_BURNER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"; fi; fi'
    '';
    sourceRoot = "${src.name}/burnerd";
    meta = {
      description = "PenguinBurner root daemon (socket API + runtime profile engine)";
      homepage = "https://github.com/jpietek/PenguinBurner";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
      mainProgram = "penguin-burnerd";
    };
  };
in
python3Packages.buildPythonApplication {
  inherit version src;
  pname = "penguin-burner";
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"PySide6-Essentials' '"pyside6'

    substituteInPlace stability/cuda_bruteforce.py \
      --replace-fail 'ctypes.util.find_library("cuda") or "libcuda.so.1"' \
        'ctypes.util.find_library("cuda") or "/run/opengl-driver/lib/libcuda.so.1"'

    substituteInPlace runtime/support/runtime_service.py \
      --replace-fail 'if job.get("type") == "auto_uv_scan" and job.get("pid") == os.getpid():' \
        'if job.get("type") in {"auto_uv_scan", "profile_verification"} and job.get("pid") == os.getpid():'
  '';
  env = {
    CMAKE_INCLUDE_PATH = "${vulkan-headers}/include";
    PENGUIN_BURNER_BUILD_DAEMON = "0";
    PENGUIN_BURNER_BUILD_NVAPI_SHIM = "0";
    dontUseCmakeConfigure = "1";
  };
  nativeBuildInputs = [ makeWrapper ];
  build-system =
    (with python3Packages; [
      setuptools
      wheel
    ])
    ++ [
      cmake
      vulkan-headers
    ];
  dependencies = deps;
  postInstall = ''
    mkdir --parents "$out/${python.sitePackages}/runtime/daemon_bin"
    makeWrapper ${penguin-burnerd}/bin/penguin-burnerd \
      "$out/${python.sitePackages}/runtime/daemon_bin/penguin-burnerd" \
      --set-default PENGUIN_BURNER_DAEMON_PROGRAM_FILE "$out/bin/.penguin-burner-cli-wrapped" \
      --set-default PENGUIN_BURNER_DAEMON_PYTHON "${python.interpreter}"
    makeWrapper ${penguin-burnerd}/bin/penguin-burnerd \
      "$out/bin/penguin-burnerd" \
      --set-default PENGUIN_BURNER_DAEMON_PROGRAM_FILE "$out/bin/.penguin-burner-cli-wrapped" \
      --set-default PENGUIN_BURNER_DAEMON_PYTHON "${python.interpreter}"
  '';
  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}:/run/opengl-driver/lib"
    "--prefix PYTHONPATH : $out/${python.sitePackages}"
    "--prefix PYTHONPATH : ${lib.makeSearchPath python.sitePackages deps}"
  ];
  pyproject = true;
  passthru = {
    daemon = penguin-burnerd;
  };
  meta = {
    description = "NVIDIA GPU automatic undervolting tool with precision V/F tuning";
    homepage = "https://github.com/jpietek/PenguinBurner";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "penguin-burner";
  };
}

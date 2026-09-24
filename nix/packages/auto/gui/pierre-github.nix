{
  lib,
  bun,
  cacert,
  fetchFromGitHub,
  nodejs,
  stdenv,
}:
stdenv.mkDerivation (_finalAttrs: {
  pname = "pierre-github";
  version = "0.1.0-unstable-2026-08-05";

  src = fetchFromGitHub {
    owner = "rudransh-shrivastava";
    repo = "pierre-github";
    rev = "c74b0afda5898df9dec90603295b2255f17bbc37";
    hash = "sha256-3vRdy+VW0hNmNliUaqLtSCNDasY5UlccZChYPvAFhB8=";
  };

  nativeBuildInputs = [
    bun
    cacert
    nodejs
  ];

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "sha256-bjBLom9BPS2sWcGXd+05nQM92HaU8RIXR0990arUjNU=";

  postPatch = ''
    substituteInPlace wxt.config.ts \
      --replace-fail "import { shikiCurate } from './scripts/shiki-curate';" "" \
      --replace-fail "plugins: [shikiCurate()]," ""
  '';

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    export CI=true
    export TERM=dumb
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    bun install --frozen-lockfile --ignore-scripts
    node ./node_modules/wxt/bin/wxt.mjs build -b firefox
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r dist/firefox-mv3/* $out/
    runHook postInstall
  '';

  meta = {
    description = "Pierre diffs and trees components for GitHub in Firefox";
    homepage = "https://github.com/rudransh-shrivastava/pierre-github";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})

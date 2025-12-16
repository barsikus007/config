{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitLab,
  libcap_ng,
  libseccomp,
}:
#? https://gitlab.com/virtio-fs/virtiofsd/-/issues/96#note_2514997399
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "virtiofsd-hreitz-fork";
  version = "8fa5564fdd4d5296997fb054a5e3193e18a81bcf"; # The specific commit hash

  src = fetchFromGitLab {
    owner = "hreitz";
    repo = "virtiofsd-rs";
    rev = finalAttrs.version; # Use the commit hash
    hash = "sha256-QjLOjH+AvF3I9ffLTRhEfwRKG7SIjTy9kQv3Q/it+hs=";
  };

  # From the original nixpkgs package, likely still relevant
  separateDebugInfo = true;

  cargoHash = "sha256-reaVHbfrHj5iZjpRaB+nREctoS3ZLdl5WGIurpRqjZU=";

  # Copied from the original nixpkgs virtiofsd package definition
  LIBCAPNG_LIB_PATH = "${lib.getLib libcap_ng}/lib";
  LIBCAPNG_LINK_TYPE = if stdenv.hostPlatform.isStatic then "static" else "dylib";

  buildInputs = [
    libcap_ng
    libseccomp
  ];

  # These phases assume '50-virtiofsd.json' exists at the root of the fetched source.
  # This file IS present at the specified commit in hreitz/virtiofsd-rs.
  postConfigure = ''
    sed -i "s|/usr/libexec|$out/bin|g" 50-virtiofsd.json
  '';

  postInstall = ''
    install -Dm644 50-virtiofsd.json "$out/share/qemu/vhost-user/50-virtiofsd.json"
  '';

  meta = with lib; {
    homepage = "https://gitlab.com/hreitz/virtiofsd-rs";
    description = "vhost-user virtio-fs device backend (hreitz/virtiofsd-rs fork at commit ${strings.substring 0 7 version})";
    platforms = platforms.linux;
    license = with licenses; [
      asl20
      bsd3
    ];
    mainProgram = "virtiofsd";
  };
})

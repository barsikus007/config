{ kernel, stdenv }:
stdenv.mkDerivation {
  inherit (kernel)
    src
    version
    postPatch
    nativeBuildInputs
    ;
  pname = "intel-iwlwifi";

  makeFlags = kernel.commonMakeFlags;

  buildPhase = ''
    BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

    cp $BUILT_KERNEL/Module.symvers .
    cp $BUILT_KERNEL/.config        .
    cp $kernel_dev/vmlinux          .

    make "-j$NIX_BUILD_CORES" $makeFlags modules_prepare
    make "-j$NIX_BUILD_CORES" $makeFlags M=$modulePath modules
  '';
  installPhase = ''
    make \
      "-j$NIX_BUILD_CORES" \
      $makeFlags \
      INSTALL_MOD_PATH="$out" \
      DEPMOD=true \
      INSTALL_MOD_STRIP=1 \
      XZ="xz --check=crc32 --threads=$NIX_BUILD_CORES" \
      M="$modulePath" \
      modules_install
  '';
  kernelVersion = kernel.modDirVersion;
  kernel_dev = kernel.dev;
  modulePath = "drivers/net/wireless/intel/iwlwifi";
  meta = {
    inherit (kernel.meta) license platforms;
    description = "iwlwifi kernel module";
  };
}

{
  stdenv,
  kernel,
}:
stdenv.mkDerivation {
  inherit (kernel)
    src
    version
    postPatch
    nativeBuildInputs
    ;
  pname = "intel-iwlwifi";
  buildPhase = ''
    BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

    cp $BUILT_KERNEL/Module.symvers .
    cp $BUILT_KERNEL/.config        .
    cp $kernel_dev/vmlinux          .

    make "-j$NIX_BUILD_CORES" modules_prepare
    make "-j$NIX_BUILD_CORES" M=$modulePath modules
  '';
  installPhase = ''
    make \
      INSTALL_MOD_PATH="$out" \
      XZ="xz --threads=$NIX_BUILD_CORES" \
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

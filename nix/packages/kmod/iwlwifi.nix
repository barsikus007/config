{
  stdenv,
  kernel,
}:
stdenv.mkDerivation {
  pname = "intel-iwlwifi";
  inherit (kernel)
    src
    version
    postPatch
    nativeBuildInputs
    ;

  kernel_dev = kernel.dev;
  kernelVersion = kernel.modDirVersion;

  modulePath = "drivers/net/wireless/intel/iwlwifi";

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
      XZ="xz -T$NIX_BUILD_CORES" \
      M="$modulePath" \
      modules_install
  '';

  meta = {
    description = "iwlwifi kernel module";
    inherit (kernel.meta) license platforms;
  };
}

{
  specialisation."VFIO".configuration = {
    system.nixos.tags = [ "with-vfio" ];
    imports = [ ./vfio.nix ];
  };
}

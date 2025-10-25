{ lib, ... }:
let
  inherit (lib)
    mkEnableOption
    ;

in
{
  options.custom = {
    isAsus = mkEnableOption "Whether the machine is an ASUS laptop.";
  };
}

{ lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;

  #? impermanence entry: a plain path or an attrset like { file = ...; method = "symlink"; }
  mkEntriesOption =
    description:
    mkOption {
      inherit description;
      type = with types; listOf (either str (attrsOf anything));
      default = [ ];
    };
in
{
  options.custom = {
    isAsus = mkEnableOption "Whether the machine is an ASUS laptop";
    blur.enable = mkEnableOption "Enable blur";

    #? feature modules declare their own state here and impermanence hosts pick it up
    #? declared on every host and every home, so writers never import the impermanence module
    persist = {
      dir = mkOption {
        type = types.str;
        default = "/persistent";
        description = "Root of the persistent filesystem";
      };
      directories = mkEntriesOption "System directories to persist";
      files = mkEntriesOption "System files to persist";
      home = {
        directories = mkEntriesOption "Directories to persist, relative to the user home";
        files = mkEntriesOption "Files to persist, relative to the user home";
      };
    };
  };
}

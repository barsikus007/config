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
    isDev = mkEnableOption "Whether the machine is for nix development";
    blur.enable = mkEnableOption "Enable blur";

    #? feature modules declare needed ports here and network module collects them into host firewall
    #? declared on every host and home so modules open ports without importing host firewall
    firewall = {
      allowedTCPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of TCP ports to open in the firewall";
      };
      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of UDP ports to open in the firewall";
      };
      allowedTCPPortRanges = mkOption {
        type = types.listOf (types.attrsOf types.port);
        default = [ ];
        description = "List of TCP port ranges to open in the firewall";
      };
      allowedUDPPortRanges = mkOption {
        type = types.listOf (types.attrsOf types.port);
        default = [ ];
        description = "List of UDP port ranges to open in the firewall";
      };
    };

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

    #? per-profile hooks run by power-profile-hook in modules/services/power-profiles.nix
    #? declared on every host, so feature modules can register actions without importing that module
    powerProfiles.actions = mkOption {
      description = "Shell snippets to run on entering each power-profiles-daemon profile";
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            performance = mkOption {
              type = types.lines;
              default = "";
            };
            balanced = mkOption {
              type = types.lines;
              default = "";
            };
            powerSaver = mkOption {
              type = types.lines;
              default = "";
            };
          };
        }
      );
    };
  };
}

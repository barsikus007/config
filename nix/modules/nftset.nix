{ lib, ... }:
let
  mkLine =
    {
      domains,
      set,
      comment ? "",
      family ? "4",
      table ? "split-routing",
    }:
    "nftset=/${lib.concatStringsSep "/" domains}/${family}#inet#${table}#${set} # ${comment}";

  sets = {
    exit = "force_exit";
    direct = "force_direct";
  };

  inherit (import ../shared/split-routing-domains.nix) groups;

  #? cidrs are skipped on purpose: dnsmasq nftset keys on domains only
  wanted = lib.filter (g: (g.enabled or true) && (g.dns or true) && (g.domains or [ ]) != [ ]) groups;
in
map (
  g:
  mkLine {
    comment = g.name;
    set = sets.${g.via};
    family = g.family or "4";
    inherit (g) domains;
  }
) wanted

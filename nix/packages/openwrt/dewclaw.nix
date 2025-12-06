{ lib, ... }:
#? https://makisekurisu.github.io/dewclaw/
# https://github.com/MakiseKurisu/dewclaw/blob/main/example/classic/example.nix
# https://github.com/MakiseKurisu/nixos-config/blob/dfae9aa4c364eab97565fd5859d10483a126385e/pkgs/dewclaw/router/default.nix
# https://github.com/shuuri-labs/shuurinet-nix/blob/356c7515d3c4c0ef67cbc4f8cdeb14b37fb76af8/flakeHelper.nix#L99
{
  openwrt = {
    "xiaomi_ax3600" = {
      deploy.host = "router";
      #? I don't want dewclaw managing packages at all?
      deploySteps.packages = {
        copy = lib.mkForce "";
        apply = lib.mkForce "";
      };
      uci.retain = [ "pbr" ];
      uci.settings = {
      };
    };
  };
}

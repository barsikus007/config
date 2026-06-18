# naming: <geo:2>-<provider:5>-<provd_subnet_id:2>-<id:2>
#    e.g: pl-hetzn-01-01; nl-digoc-01-01; nl-digoc-01-02
{
  imports = [
    ../.
    ../vps
    ../../modules/cachyos-kernel.nix

    ../../modules/copy-flake.nix

    ../../modules/wireguard/server/multihop.nix
    ../../modules/wireguard/server/multihop-egress.nix
  ];
}

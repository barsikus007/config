# naming: <geo:2>-<provider:5>-<provd_subnet_id:2>-<id:2>
#    e.g: pl-hetzn-01-01; nl-digoc-01-01; nl-digoc-01-02
{
  imports = [
    ../.
    ../vps

    ../../modules/copy-flake.nix

    ../../modules/wireguard/server/multihop.nix
    ../../modules/wireguard/server/multihop-egress.nix
    ../../modules/wireguard/server/dns.nix
    ../../modules/wireguard/server/ui.nix
    ../../modules/services/networking/free-turn-proxy.nix
  ];

  services.free-turn-proxy.server = {
    enable = true;
    connect = "127.0.0.1:51820";
    obfProfile = "rtpopus3";
    obfKeyFile = "/etc/free-turn-proxy/obf-key";
    # TODO: secrets: free-turn-proxy-server -gen-obf-key 2>/dev/null | sudo install -D --mode=600 /dev/stdin /etc/free-turn-proxy/obf-key
    # TODO: secrets: nix run nixpkgs#openssl -- rand -hex 32 | sudo install -D --mode=600 /dev/stdin /etc/free-turn-proxy/obf-key
    #! pipe, not <(...): sudo closes inherited fds, so /proc/self/fd/N dies under root
    # obfKeyFile = config.sops.secrets."hosts/xxx/ftp/obf-key".path;
    openFirewall = true;
  };
}

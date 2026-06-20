#! vibed topology:
#?   infranet_client --wg0--> infranet_node --(direct, vlan4)--> infranet_wan_site       (203.0.113.50,  "INFRANET")
#?                   infranet_node --wg1--> internet_node --(vlan3)--> internet_wan_site (198.51.100.50, "INTERNET")
#?   infranet_wan_site is reachable ONLY directly from infranet_node (exit has no route to it)
#?   internet_wan_site ONLY via the exit (infranet_node has no route to it), so:
#?     - a successful INFRANET fetch proves the dst WAS NOT marked (ru_ips bypass works)
#?     - a successful INTERNET fetch proves the dst WAS     marked and left via wg1
{ pkgs, ... }:
let
  #? wg genkey
  clientPriv = "eGa1uo9xokUKWg54aDMk4RHXTgtKDq85OWvC/TFzeGU=";
  clientPub = "zjtaPJ58CxuDLjNx0NvmnZB+a7ksZAWTeKExnhKUNlk=";
  infranetWg0Priv = "QC0U3ibJYgLP5xHER1S4kU39MbZAZrR9qLWCBnP9n1E=";
  infranetWg0Pub = "kfbqa22XjMRpvPJj3g4RXUsuFkNnUYWFP9YS8uRDIBU=";
  infranetWg1Priv = "WKC8i7j6CykoDQMVBcWkkZliN2/1Yw6s8z233BSmAks=";
  infranetWg1Pub = "n2Cd0bHYdObXevu438JO0ckEMx6pZq+X/7pZhS/6bwM=";
  exitPriv = "QI0darFpR4/IDJjvghvqf6V6xB1b5NF6c27uDFa5ykw=";
  exitPub = "jY1+N8zr/MDhJMYQnuW1XcrbkVa+YCmhaf78FASifxI=";

  keyFile = name: priv: toString (pkgs.writeText name priv);

  #? infranet_client tunnel (wg0) and exit tunnel (wg1) subnets
  clientWg = "10.100.0";
  exitWg = "10.200.0";

  #? simulated internet targets
  infranetWanSiteIp = "203.0.113.50"; # ? reachable ONLY directly from infranet_node (vlan4)
  infranetWanSiteGw = "203.0.113.1"; # ? infranet_node's address on that segment
  foreignSiteIp = "198.51.100.50"; # ? reachable ONLY via the exit (vlan3)
  foreignSiteGw = "198.51.100.1"; # ? internet_node's address on that segment

  webRoot = body: {
    enable = true;
    adminAddr = "test@example.com";
    virtualHosts.localhost.documentRoot = pkgs.writeTextDir "index.html" body;
  };
in
pkgs.testers.runNixOSTest {
  #! vlans
  #? vlan1 - infranet_client
  #? vlan2 - infranet to internet
  #? vlan3 - infranet_wan
  #? vlan4 - internet_wan
  name = "KBH-multihop";

  nodes = {
    infranet_node =
      {
        lib,
        pkgs,
        nodes,
        ...
      }:
      {
        virtualisation.vlans = [
          1
          2
          4
        ];
        networking.interfaces.eth3.ipv4.addresses = [
          {
            address = infranetWanSiteGw;
            prefixLength = 24;
          }
        ];

        imports = [
          ../modules/wireguard/server/ui.nix
          (import ../modules/wireguard/server/multihop.nix {
            inherit pkgs;
            ruListUrl = "http://${nodes.infranet_list_serve.networking.primaryIPAddress}/infranet.json";
          })
          (import ../modules/wireguard/server/multihop-egress.nix {
            outInterfaceCfg = {
              address = [ "${exitWg}.1/24" ];
              privateKeyFile = keyFile "infranet-wg1.key" infranetWg1Priv;
              peers = [
                {
                  publicKey = exitPub;
                  allowedIPs = [ "0.0.0.0/0" ];
                  endpoint = "${nodes.internet_node.networking.primaryIPAddress}:51821";
                  persistentKeepalive = 25;
                }
              ];
            };
          })
        ];

        networking.wg-quick.interfaces.wg0 = lib.mkForce {
          address = [ "${clientWg}.1/24" ];
          listenPort = 51820;
          privateKeyFile = keyFile "infranet-wg0.key" infranetWg0Priv;
          peers = [
            {
              publicKey = clientPub;
              allowedIPs = [ "${clientWg}.2/32" ];
            }
          ];
        };
      };

    infranet_client =
      { pkgs, nodes, ... }:
      {
        virtualisation.vlans = [ 1 ];
        environment.systemPackages = with pkgs; [ curl ];
        networking.wg-quick.interfaces.wg0 = {
          address = [ "${clientWg}.2/24" ];
          privateKeyFile = keyFile "client.key" clientPriv;
          peers = [
            {
              publicKey = infranetWg0Pub;
              allowedIPs = [ "0.0.0.0/0" ];
              endpoint = "${nodes.infranet_node.networking.primaryIPAddress}:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };

    internet_node = {
      virtualisation.vlans = [
        2
        3
      ];
      networking.firewall.checkReversePath = "loose";
      networking.firewall.allowedUDPPorts = [ 51821 ];
      networking.nat = {
        enable = true;
        internalInterfaces = [ "wg1" ];
        externalInterface = "eth2";
      };
      networking.interfaces.eth2.ipv4.addresses = [
        {
          address = foreignSiteGw;
          prefixLength = 24;
        }
      ];
      networking.wg-quick.interfaces.wg1 = {
        address = [ "${exitWg}.2/24" ];
        listenPort = 51821;
        privateKeyFile = keyFile "exit.key" exitPriv;
        peers = [
          {
            publicKey = infranetWg1Pub;
            allowedIPs = [ "${exitWg}.1/32" ];
          }
        ];
      };
    };

    infranet_wan_site = {
      virtualisation.vlans = [ 4 ];
      networking.interfaces.eth1.ipv4.addresses = [
        {
          address = infranetWanSiteIp;
          prefixLength = 24;
        }
      ];
      networking.firewall.allowedTCPPorts = [ 80 ];
      services.httpd = webRoot "INFRANET_WAN_SITE";
    };

    internet_wan_site = {
      virtualisation.vlans = [ 3 ];
      networking.interfaces.eth1.ipv4.addresses = [
        {
          address = foreignSiteIp;
          prefixLength = 24;
        }
      ];
      networking.firewall.allowedTCPPorts = [ 80 ];
      services.httpd = webRoot "INTERNET_WAN_SITE";
    };

    infranet_list_serve =
      { pkgs, ... }:
      {
        virtualisation.vlans = [ 1 ];
        networking.firewall.allowedTCPPorts = [ 80 ];
        services.httpd = {
          enable = true;
          adminAddr = "test@example.com";
          virtualHosts.localhost.documentRoot = pkgs.writeTextDir "infranet.json" (
            builtins.toJSON {
              data.resources.ipv4 = [ "${infranetWanSiteIp}/32" ];
            }
          );
        };
      };
  };

  testScript = /* python */ ''
    start_all()

    infranet_list_serve.wait_for_unit("httpd.service")
    infranet_wan_site.wait_for_unit("httpd.service")
    internet_wan_site.wait_for_unit("httpd.service")
    infranet_node.wait_for_unit("wg-quick-wg0.service")
    infranet_node.wait_for_unit("wg-quick-wg1.service")
    internet_node.wait_for_unit("wg-quick-wg1.service")
    infranet_client.wait_for_unit("wg-quick-wg0.service")
    infranet_node.wait_for_unit("multi-user.target")

    # update-ru-routes is a oneshot (no RemainAfterExit); start it explicitly so the
    # call blocks until completion, then confirm the INFRANET prefix landed in the set.
    infranet_node.succeed("systemctl start update-ru-routes.service")
    infranet_node.succeed("nft list set inet split-routing ru_ips | grep -F ${infranetWanSiteIp}")

    # The wg1 policy routing must be in place (fwmark 0x78 == 120).
    infranet_node.succeed("ip rule show | grep -F 'fwmark 0x78'")
    infranet_node.succeed("ip route show table 120 | grep -F wg1")

    # Bring the tunnels to a known-good state before asserting reachability.
    infranet_node.wait_until_succeeds("ping -c1 ${exitWg}.2", timeout=30)
    infranet_client.wait_until_succeeds("ping -c1 ${clientWg}.1", timeout=30)

    # INFRANET dst: in ru_ips, non-rfc1918 -> NOT marked -> direct egress from infranet_node.
    # (internet_node has no route here, so success proves the bypass.)
    infranet_client.succeed("curl --fail --max-time 10 http://${infranetWanSiteIp}/ | grep -F INFRANET_WAN_SITE")

    # INTERNET dst: not INFRANET, not rfc1918 -> marked 120 -> table 120 -> wg1 -> exit.
    # (infranet_node has no direct route here, so success proves the marking + routing.)
    infranet_client.succeed("curl --fail --max-time 10 http://${foreignSiteIp}/ | grep -F INTERNET_WAN_SITE")
  '';
}

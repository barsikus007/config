{ pkgs, config, ... }:
let
  logpath = "/var/log/x-ui/3xipl.log";
  chain = "DOCKER-USER";
  exemptports = builtins.concatStringsSep "," (map toString config.services.openssh.ports);
in
#? https://github.com/MHSanaei/3x-ui/blob/f3eba04ed8375394b571d89b07d01dc64e54aae9/DockerEntrypoint.sh#L12
{
  services.fail2ban = {
    enable = true;
    extraPackages = with pkgs; [ iptables ];

    #! sudo fail2ban-client status --all
    #! sudo fail2ban-client unban --all
    jails.x3ipl = {
      filter.Definition = {
        datepattern = "^%%Y/%%m/%%d %%H:%%M:%%S";
        failregex = ''\[LIMIT_IP\]\s*Email\s*=\s*<F-USER>.+</F-USER>\s*\|\|\s*Disconnecting OLD IP\s*=\s*<ADDR>\s*\|\|\s*Timestamp\s*=\s*\d+'';
        ignoreregex = "";
      };
      settings = {
        inherit logpath;
        backend = "auto";
        action = "3x-ipl";
        maxretry = 1;
        findtime = 32;
        bantime = "30m";
      };
    };
  };

  #! `2>/dev/null || true` added for idempotency
  environment.etc."fail2ban/action.d/3x-ipl.conf".text = ''
    [INCLUDES]
    before = iptables-allports.conf

    [Definition]
    actionstart = <iptables> --new-chain f2b-<name> 2>/dev/null || true
                  <iptables> --check f2b-<name> --jump <returntype> 2>/dev/null || <iptables> --append f2b-<name> --jump <returntype>
                  <iptables> --check <chain> --jump f2b-<name> 2>/dev/null || <iptables> --insert <chain> --jump f2b-<name>
    actionstop  = <iptables> --delete <chain> --jump f2b-<name> 2>/dev/null || true
                  <actionflush>
                  <iptables> --delete-chain f2b-<name> 2>/dev/null || true
    actioncheck = <iptables> --numeric --list <chain> | grep --quiet 'f2b-<name>[ \t]'
    actionban   = <iptables> --insert f2b-<name> 1 --source <ip> --protocol tcp --match multiport ! --dports <exemptports> --jump <blocktype>
                  <iptables> --insert f2b-<name> 1 --source <ip> --protocol udp --match multiport ! --dports <exemptports> --jump <blocktype>
    actionunban = <iptables> --delete f2b-<name> --source <ip> --protocol tcp --match multiport ! --dports <exemptports> --jump <blocktype>
                  <iptables> --delete f2b-<name> --source <ip> --protocol udp --match multiport ! --dports <exemptports> --jump <blocktype>

    [Init]
    name = default
    chain = ${chain}
    exemptports = ${exemptports}
  '';
}

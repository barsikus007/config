{ pkgs, config, ... }:
let
  logpath = "/var/log/x-ui/3xipl.log";
  chain = "DOCKER-USER";
  exemptports = builtins.concatStringsSep "," (map toString (config.services.openssh.ports));
in
#? https://github.com/MHSanaei/3x-ui/blob/f3eba04ed8375394b571d89b07d01dc64e54aae9/DockerEntrypoint.sh#L12
{
  services.fail2ban = {
    enable = true;
    extraPackages = with pkgs; [ iptables ];

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
    actionstart = <iptables> -N f2b-<name> 2>/dev/null || true
                  <iptables> -C f2b-<name> -j <returntype> 2>/dev/null || <iptables> -A f2b-<name> -j <returntype>
                  <iptables> -C <chain> -j f2b-<name> 2>/dev/null || <iptables> -I <chain> -j f2b-<name>
    actionstop  = <iptables> -D <chain> -j f2b-<name> 2>/dev/null || true
                  <actionflush>
                  <iptables> -X f2b-<name> 2>/dev/null || true
    actioncheck = <iptables> -n -L <chain> | grep -q 'f2b-<name>[ \t]'
    actionban   = <iptables> -I f2b-<name> 1 -s <ip> -p tcp -m multiport ! --dports <exemptports> -j <blocktype>
                  <iptables> -I f2b-<name> 1 -s <ip> -p udp -m multiport ! --dports <exemptports> -j <blocktype>
    actionunban = <iptables> -D f2b-<name> -s <ip> -p tcp -m multiport ! --dports <exemptports> -j <blocktype>
                  <iptables> -D f2b-<name> -s <ip> -p udp -m multiport ! --dports <exemptports> -j <blocktype>

    [Init]
    name = default
    chain = ${chain}
    exemptports = ${exemptports}
  '';
}

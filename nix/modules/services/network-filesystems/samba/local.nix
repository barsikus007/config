{
  # TODO: unstable: hydra-check samba4Full
  # services.samba.package = pkgs.samba4Full;
  services.avahi.extraServiceFiles.smb = /* xml */ ''
    <?xml version="1.0" standalone='no'?><!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">%h</name>
      <service>
        <type>_smb._tcp</type>
        <port>445</port>
      </service>
    </service-group>
  '';

  services.samba.settings.global = {
    #? loopback + RFC1918 + link-local + IPv6 loopback/ULA/link-local
    "hosts allow" =
      "127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 169.254.0.0/16 192.168.0.0/16 ::1 fc00::/7 fe80::/10";

    #? acl_xattr: store Windows ACLs as xattr
    #? fruit+streams_xattr: macOS SMB quirks and resource fork support
    #? io_uring: async I/O for better throughput (must be last parameter)
    "vfs objects" = "acl_xattr fruit streams_xattr io_uring";
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true; # ? resolve .local hostnames (e.g. nas.local)
    publish = {
      enable = true;
      userServices = true; # ? let samba auto-register the SMB service in mDNS
    };
  };
}

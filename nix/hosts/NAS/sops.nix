{
  imports = [ ../../modules/sops.nix ];

  sops.defaultSopsFile = ../../secrets/hosts/NAS.yaml;
  sops.age.sshKeyPaths = [ "/persistent/etc/ssh/ssh_host_ed25519_key" ];
}

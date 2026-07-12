# Overlay applied on top of the real NAS config to make
# `nixos-anywhere --flake ./nix#NAS-vmtest --vm-test` pass.
#
# The disko vm-test harness runs fully non-interactively and only ever
# provisions /tmp/secret.key (= "secretsecret"). The production config relies on
# interactive / external-key ceremony that cannot run in that environment:
#   * zroot does `change-key -o keylocation=prompt` (interactive at boot),
#   * tank reads its key from /etc/zfs/keys/tank.key which nothing creates,
#   * secrets come from sops, which cannot decrypt without the host key.
# Here we neutralize those steps for the test only; the real NAS config stays
# untouched.
{ lib, modulesPath, ... }:
let
  #? key the disko vm-test seeds into /tmp/secret.key
  testKey = "secretsecret";

  #! rootPool is imported in the initrd, so its key must live there; every
  #! dataPool is imported in stage 2 by its own zfs-import-<pool> service
  rootPool = "zroot";
  dataPools = [ "tank" ];
  allPools = [ rootPool ] ++ dataPools;

  #? create straight from a seeded key file (copied from the test's
  #? /tmp/secret.key) and persist a file:// keylocation, instead of the
  #? /tmp -> change-key/prompt dance the real config uses
  poolOverride = name: {
    postCreateHook = lib.mkForce "";
    rootFsOptions.keylocation = lib.mkForce "file:///etc/zfs/keys/${name}.key";
    preCreateHook = lib.mkForce ''
      mkdir -p /etc/zfs/keys
      cp /tmp/secret.key /etc/zfs/keys/${name}.key
    '';
  };
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  disko.devices.zpool = lib.mkMerge [
    (lib.genAttrs allPools poolOverride)
    {
      # the disko vm-test only gives each disk 4 GiB, so the production 16G swap
      # zvol does not fit on zroot ("out of space"); shrink it for the test
      ${rootPool}.datasets.swap.size = lib.mkForce "512M";
    }
  ];

  # rootPool is imported in the (systemd) initrd, so its key must live there
  boot.initrd.systemd.contents."/etc/zfs/keys/${rootPool}.key".text = testKey;

  systemd.services = lib.mkMerge [
    # each dataPool is imported in stage 2 by zfs-import-<pool>.service, which
    # runs in sysinit - before NixOS lays out /etc, so `environment.etc` would be
    # too late; seed the key in the service's own preStart instead
    (lib.listToAttrs (
      map (pool: {
        name = "zfs-import-${pool}";
        value.preStart = ''
          mkdir -p /etc/zfs/keys
          printf '%s' ${testKey} > /etc/zfs/keys/${pool}.key
        '';
      }) dataPools
    ))

    # `switch-to-configuration boot` runs activation/bootloader steps that need
    # secrets unavailable in the test VM; neutralize the one that hard-fails:
    # samba-passwd reads a sops secret (/run/secrets/.../smb/passwd)
    { samba-passwd.enable = lib.mkForce false; }
  ];

  # initrd SSH copies a host key from /persistent which does not exist in the
  # test, breaking bootloader installation; remote unlock is irrelevant here
  boot.initrd.network.ssh.enable = lib.mkForce false;
}

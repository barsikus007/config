{ pkgs, username, ... }:
{
  users.users.${username}.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    android-tools
    android-file-transfer
    (callPackage ../packages/adbfs-rootless-libfuse-3.nix { })
  ];
}

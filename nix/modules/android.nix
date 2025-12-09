{ pkgs, username, ... }:
{
  programs.adb.enable = true;
  users.users.${username}.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    android-file-transfer
    (callPackage ../packages/adbfs-rootless-libfuse-3.nix { })
  ];
}

{
  pkgs,
  self,
  username,
  ...
}:
{
  users.users.${username}.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    android-tools
    android-file-transfer
    self.packages.${system}.soft.adbfs-rootless-libfuse-3
  ];
}

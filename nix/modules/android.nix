{
  pkgs,
  self,
  username,
  ...
}:
{
  imports = [
    ./android-scrcpy-camera.nix
  ];

  custom.persist.home.directories = [ ".android" ];

  users.users.${username}.extraGroups = [ "adbusers" ];

  environment.systemPackages = with pkgs; [
    android-tools
    android-file-transfer
    self.packages.${stdenv.hostPlatform.system}.adbfs-rootless-libfuse-3
  ];
}

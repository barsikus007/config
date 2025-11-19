{ config, flakePath, ... }:
{
  services.ludusavi.enable = true;
  services.ludusavi.settings = { };
  services.ludusavi.configFile = config.lib.file.mkOutOfStoreSymlink "${flakePath}/.config/ludusavi/config.yaml";
}

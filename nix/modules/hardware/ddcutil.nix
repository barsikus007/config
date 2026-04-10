{ pkgs, username, ... }:
#? display brightness control (plasma does this natively ;-;)
{
  hardware.i2c.enable = true;
  users.users.${username}.extraGroups = [ "i2c" ];
  environment.systemPackages = with pkgs; [
    ddcutil
  ];
}

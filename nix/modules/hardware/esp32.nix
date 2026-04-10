{ username, ... }:
{
  #? allow to use /dev/ttyUSB* devices
  users.users.${username}.extraGroups = [ "dialout" ];
}

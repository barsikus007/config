{ lib, config, ... }:
#? "Enable helpful DBus services." section from plasma6 nixos module
let
  inherit (lib) mkDefault;
in
{
  services.accounts-daemon.enable = true;
  # when changing an account picture the accounts-daemon reads a temporary file containing the image which systemsettings5 may place under /tmp
  systemd.services.accounts-daemon.serviceConfig.PrivateTmp = false;

  services.power-profiles-daemon.enable = mkDefault true;
  # services.system-config-printer.enable = mkIf config.services.printing.enable (mkDefault true);
  # services.udisks2.enable = true;
  services.upower.enable = config.powerManagement.enable;
  # services.libinput.enable = mkDefault true;
  # services.geoclue2.enable = mkDefault true;
  services.fwupd.enable = mkDefault true;
}

{
  lib,
  pkgs,
  config,
  username,
  ...
}:
#? https://github.com/nix-community/nur-combined/blob/301a494ecb37bafb1a31d588844c7999b90c5821/repos/mich-adams/modules/user-icon.nix
let
  userIcon = pkgs.fetchurl {
    url = "https://github.com/barsikus007.png";
    sha256 = "sha256-9uVU2KzX97TGS51lgwL8JqdSbX7kbl1uJRDTWo3Mpsg=";
  };
  defaultSession = config.services.displayManager.defaultSession;
  session = lib.optionalString (
    defaultSession != null
  ) "Session=${defaultSession}\\nSessionType=wayland\\n";
in
{
  systemd.tmpfiles.rules = [
    #? "\\n" passes literal "\n" to systemd
    "f+ /var/lib/AccountsService/users/${username} - - - - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n${session}\\n"
    "L+ /var/lib/AccountsService/icons/${username} - - - - ${userIcon}"
    #? for noctalia
    "L+ /home/${username}/.face - ${username} users - ${userIcon}"
  ];
}

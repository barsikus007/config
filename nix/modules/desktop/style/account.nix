{ username, ... }:
#? https://github.com/nix-community/nur-combined/blob/301a494ecb37bafb1a31d588844c7999b90c5821/repos/mich-adams/modules/user-icon.nix
let
  userIcon = builtins.fetchurl {
    url = "https://github.com/barsikus007.png";
    sha256 = "sha256-9uVU2KzX97TGS51lgwL8JqdSbX7kbl1uJRDTWo3Mpsg=";
  };
in
{
  systemd.tmpfiles.rules = [
    #? notice the "\\n" we don't want nix to insert a new line in our string, just pass it as \n to systemd
    "f+ /var/lib/AccountsService/users/${username} - - - - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n"
    "L+ /var/lib/AccountsService/icons/${username} - - - - ${userIcon}"
    #? for noctalia-shell
    "L+ /home/${username}/.face - ${username} users - ${userIcon}"
  ];
}

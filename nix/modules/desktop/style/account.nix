{ username, ... }:
#? https://github.com/nix-community/nur-combined/blob/301a494ecb37bafb1a31d588844c7999b90c5821/repos/mich-adams/modules/user-icon.nix
let
  userIcon = builtins.fetchurl {
    url = "https://github.com/barsikus007.png";
    sha256 = "sha256-ifkRxN8PTXOp7zkM8NcEWptT7scvMVkGZlcUs6B+0Dk=";
  };
in
{
  systemd.tmpfiles.rules = [
    #? notice the "\\n" we don't want nix to insert a new line in our string, just pass it as \n to systemd
    "f+ /var/lib/AccountsService/users/${username} - - - - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\n"
    "L+ /var/lib/AccountsService/icons/${username} - - - - ${userIcon}"
    # TODO: check if plasma will get it from accountservice
    # "L+ /home/${username}/.face.icon - - - - ${userIcon}"
    # "L+ /home/${username}/.face.icon - ${username} users - ${userIcon}"
  ];
}

{ lib, username, ... }:
{
  users.users.${username}.openssh.authorizedKeys.keys = [
    (lib.strings.removeSuffix "\n" (
      builtins.readFile (
        builtins.fetchurl {
          url = "https://github.com/barsikus007.keys";
          sha256 = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
        }
      )
    ))
  ];
  services.openssh = {
    enable = true;
    ports = lib.mkDefault [ 2222 ];
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}

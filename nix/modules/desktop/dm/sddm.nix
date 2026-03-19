{ lib, config, ... }:
{

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      autoLogin.relogin = true;
    };
  };
  #? https://wiki.nixos.org/wiki/Fingerprint_scanner#Login
  #! https://github.com/NixOS/nixpkgs/issues/171136#issuecomment-2918400189
  security.pam.services.sddm.text = lib.mkForce (
    lib.strings.concatLines (
      builtins.filter (x: (lib.strings.hasPrefix "auth " x) && (!lib.strings.hasInfix "fprintd" x)) (
        lib.strings.splitString "\n" config.security.pam.services.login.text
      )
    )
    + ''

      account   include   login
      password  substack  login
      session   include   login
    ''
  );
}

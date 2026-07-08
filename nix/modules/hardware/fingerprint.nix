{
  lib,
  pkgs,
  self,
  config,
  ...
}:
#? dev notes https://web.archive.org/web/20240913070409/https://infinytum.co/fixing-my-fingerprint-reader-on-linux-by-writing-a-driver-for-it/
#? windows dual-boot https://www.reddit.com/r/ZephyrusG14/comments/ql2opr/comment/hj2grmo/
{
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override {
      libfprint = self.packages.${pkgs.stdenv.hostPlatform.system}.libfprint-goodixtls-27c6-521d;
    };
  };

  #? cause fprint is fucked up in greetd
  security.pam.services.greetd.fprintAuth = lib.mkIf config.services.greetd.enable false;
}

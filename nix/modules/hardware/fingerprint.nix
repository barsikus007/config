{ pkgs, ... }:
#? dev notes https://web.archive.org/web/20240913070409/https://infinytum.co/fixing-my-fingerprint-reader-on-linux-by-writing-a-driver-for-it/
#? windows dual-boot https://www.reddit.com/r/ZephyrusG14/comments/ql2opr/comment/hj2grmo/
{
  services.fprintd = {
    enable = true;
    package = pkgs.previous.fprintd.override {
      libfprint = pkgs.previous.callPackage ../../packages/libfprint-27c6-521d.nix { };
    };
  };
  #! cause it breaks SDDM wallet and password auth
  #? https://wiki.nixos.org/wiki/Fingerprint_scanner#Login
  security.pam.services.login.fprintAuth = false;
}

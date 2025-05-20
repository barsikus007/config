{ pkgs, ... }:
#? dev notes https://web.archive.org/web/20240913070409/https://infinytum.co/fixing-my-fingerprint-reader-on-linux-by-writing-a-driver-for-it/
#? windows dual-boot https://www.reddit.com/r/ZephyrusG14/comments/ql2opr/comment/hj2grmo/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
{
  services.fprintd = {
    enable = true;
    package = pkgs.previous.fprintd.override {
      libfprint = pkgs.previous.callPackage ../../packages/libfprint-27c6-521d.nix { };
    };
  };
  #! cause it breaks SDDM wallet and password auth
  security.pam.services.login.fprintAuth = false;
}

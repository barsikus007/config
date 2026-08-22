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
  custom.persist.directories = [ "/var/lib/fprint" ]; # ? enrolled fingerprints

  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override {
      libfprint = self.packages.${pkgs.stdenv.hostPlatform.system}.libfprint-goodixtls-27c6-521d;
    };
  };

  #! the goodixtls driver has no suspend/resume, so the device is dead after S3
  #! ("Receive data error: device was disconnected") while the daemon keeps a stale
  #! claim: the lockscreen's verify then hangs ~30s until the dbus timeout
  #? stopping it before sleep leaves no stale claim to hit, and Type=dbus brings
  #? the daemon back on the first verify, already on the re-enumerated device
  #! || true: this runs under set -e, and a failure here skips ExecStop of the
  #! same unit, where resumeCommands of every module live
  #? the lockscreen claims the device at lock time, so its first VerifyStart after
  #? resume fails with ClaimDevice and it re-claims 250ms later, one expected error
  powerManagement.powerDownCommands = ''
    ${lib.getExe' pkgs.systemd "systemctl"} stop fprintd.service || true
  '';

  #? cause fprint is fucked up in greetd
  security.pam.services.greetd.fprintAuth = lib.mkIf config.services.greetd.enable false;
}

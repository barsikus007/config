{
  lib,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./.
    ../extra.nix
    ./sunshined-vfio.nix
    ../../modules/stylix.nix
    ../../modules/desktop/manager/niri.nix
  ];

  home-manager.users.${username}.xdg.configFile."niri/config.kdl".source = lib.mkForce (
    pkgs.runCommand "niri-config-coolvm.kdl" { } ''
      ${lib.getExe pkgs.gnused} \
        -e 's|render-drm-device .*|render-drm-device "/dev/dri/renderD128"|' \
        -e '/ignore-drm-device/d' \
        ${../../.config/niri/config.kdl} > $out
    ''
  );
}

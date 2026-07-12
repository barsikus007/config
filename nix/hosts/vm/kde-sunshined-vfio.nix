{
  imports = [
    ./.
    ../extra.nix
    ./sunshined-vfio.nix
    ../../modules/stylix.nix
    ../../modules/desktop/manager/plasma.nix
  ];

  #! pin KWin to the nvidia KMS device so it doesn't composite on the emulated bochs (analog of the
  #! niri render-drm-device patch). KWIN_DRM_DEVICES is COLON-separated -> a by-path node breaks it
  environment.sessionVariables.KWIN_DRM_DEVICES = "/dev/dri/card1";
}

{ pkgs, ... }:
{
  fonts = {
    # fix furryfox fonts
    enableDefaultPackages = true;
    fontconfig.useEmbeddedBitmaps = true;
    packages = with pkgs; [
      # fix furryfox JAP pixelated fonts
      noto-fonts-cjk-sans

      # office fonts
      corefonts

      # minecraft-like fonts
      monocraft
      miracode
      (callPackage ../../packages/minecraftia.nix { })
    ];
  };
}

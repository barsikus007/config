{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      bcompare5 = (pkgs.libsForQt5.callPackage ../../packages/bcompare5.nix { });
    })
    (self: super: {
      bcompare5 = super.bcompare5.overrideAttrs (old: {
        #? sorry, I can't buy this software right now (and trial don't work)
        #? https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67?permalink_comment_id=5168755#gistcomment-5168755
        postFixup = ''
          sed -i "s/AlPAc7Np1/AlPAc7Npn/g" $out/lib/beyondcompare/BCompare
        '';
      });
    })
  ];

  home.packages = with pkgs; [
    bcompare5
    cifs-utils # to mount smb cause smb:// don't work
  ];
}

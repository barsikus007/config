{ fetchurl, bcompare }:
let
  #? https://www.scootersoftware.com/download/v5changelog
  version = "5.2.7.32913";
in
bcompare.overrideAttrs (previousAttrs: {
  inherit version;

  src = fetchurl {
    url = "https://www.scootersoftware.com/files/bcompare-${version}_amd64.deb";
    hash = "sha256-eIPukT6BtXe8CS5EUeaz2xOPMSJ+bt/CtYpdOs0VcfQ=";
  };

  installPhase = (previousAttrs.installPhase or "") + ''
    # prefer native wayland (fixes DnD via xwayland bridge), fall back to xcb or user override
    substituteInPlace $out/bin/bcompare \
      --replace-fail "QT_QPA_PLATFORM=xcb" 'QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-wayland;xcb}"'
  '';

  #? sorry, I can't buy this software right now (and trial doesn't work)
  #? https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67?permalink_comment_id=5168755#gistcomment-5168755
  postFixup = (previousAttrs.postFixup or "") + ''
    # redirect /usr/share/zoneinfo to /etc/zoneinfo (exact 19 bytes) to fix profiles hang
    sed --in-place "s|/usr/share/zoneinfo|/etc/./././zoneinfo|g" $out/lib/beyondcompare/BCompare
    sed --in-place "s/AlPAc7Np1/AlPAc7Npn/g" $out/lib/beyondcompare/BCompare
  '';
})

{ bcompare, fetchurl }:
let
  #? https://www.scootersoftware.com/download/v5changelog
  version = "5.2.5.32528";

  src = fetchurl {
    url = "https://www.scootersoftware.com/files/bcompare-${version}_amd64.deb";
    sha256 = "sha256-kMIk2cH3fJqPIif0UVMYk6o19imV00uP6zX10MaYKJs=";
  };
in
bcompare.overrideAttrs (previousAttrs: {
  inherit src version;

  installPhase = (previousAttrs.installPhase or "") + ''
    # Prefer native wayland (fixes DnD via xwayland bridge), fall back to xcb on X sessions
    substituteInPlace $out/bin/bcompare \
      --replace-fail "QT_QPA_PLATFORM=xcb" 'QT_QPA_PLATFORM="wayland;xcb"'
  '';

  #? sorry, I can't buy this software right now (and trial doesn't work)
  #? https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67?permalink_comment_id=5168755#gistcomment-5168755
  postFixup = (previousAttrs.postFixup or "") + ''
    sed --in-place "s/AlPAc7Np1/AlPAc7Npn/g" $out/lib/beyondcompare/BCompare
  '';
})

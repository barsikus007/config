{ fetchurl, bcompare }:
#? https://www.scootersoftware.com/download/v5changelog
let
  version = "5.2.8.33052";
in
bcompare.overrideAttrs (previousAttrs: {
  inherit version;

  src = fetchurl {
    url = "https://www.scootersoftware.com/files/bcompare-${version}_amd64.deb";
    hash = "sha256-aRl4aEKEMrYeJUJ3yixifzsD5UuMSMZVstMCBefweRs=";
  };

  #? sorry, I can't buy this software right now (and trial doesn't work)
  #? https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67?permalink_comment_id=5168755#gistcomment-5168755
  postFixup = (previousAttrs.postFixup or "") + ''
    sed --in-place "s/AlPAc7Np1/AlPAc7Npn/g" $out/lib/beyondcompare/BCompare
  '';
})

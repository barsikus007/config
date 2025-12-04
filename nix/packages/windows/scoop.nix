{
  lib,
  fetchFromGitHub,
  runCommand,
  git,
}:
let

  scoopBuckets = [
    {
      name = "main";
      owner = "ScoopInstaller";
      repo = "Main";
      rev = "7439a1bd990a9d5e9fbdff9f045b6b58b2521724";
      hash = "sha256-tvzDTsoZUJwdxNVMJxu49xhIsA9E5XRr/78BDyFXS2o=";
    }
    {
      name = "extras";
      owner = "ScoopInstaller";
      repo = "Extras";
      rev = "32d754589df86c576bf218b796afe0e6de60a8c6";
      hash = "sha256-wFfqBAzdniuHBWsi1k/fHhW6tX9lTGv/h3/kT3M4578=";
    }
    # postFetch = ''
    #   mkdir -p $out/.git/refs/{heads,remotes}
    #   echo ${rev} > $out/.git/refs/heads/master
    #   echo "ref: refs/remotes/origin/master" >
    # '';
  ];
  scoopPackages = [
    "main/aria2"
    "main/7zip"
  ];

  # TODO: scoopPackages: scoop/cache
  # TODO: finish bucket .git hydration
in
runCommand "scoop-dir"
  {
    nativeBuildInputs = [ git ];
    meta.description = ''Hydrate scoop with nix'';
  }
  ''
    ${lib.strings.concatStringsSep "\n" (
      lib.lists.forEach scoopBuckets (bucket: ''
        BUCKET_DIR=$out/buckets/${bucket.name}
        mkdir -p "$BUCKET_DIR"
        cp -a ${
          fetchFromGitHub {
            inherit (bucket)
              owner
              repo
              rev
              hash
              ;
            leaveDotGit = true;
          }
        }/. $BUCKET_DIR
        cd "$BUCKET_DIR"
        chmod +w -R .git

        echo -e '[core]
        \trepositoryformatversion = 0
        \tfilemode = true
        \tbare = false
        \tlogallrefupdates = true
        [remote "origin"]
        \turl = https://github.com/ScoopInstaller/${bucket.repo}
        \tfetch = +refs/heads/*:refs/remotes/origin/*
        [branch "master"]
        \tremote = origin
        \tmerge = refs/heads/master' > .git/config

        echo "ref: refs/heads/master" > .git/HEAD
        echo ${bucket.rev} > .git/refs/heads/master
        git reset
        # git branch --set-upstream-to=origin/master master

        cd -
      '')
    )}
    mkdir $out/cache
  ''

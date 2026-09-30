{
  lib,
  fetchurl,
  fetchFromGitHub,
  git,
  runCommand,
  zip,
  scoopBuckets ? [
    {
      name = "main";
      owner = "ScoopInstaller";
      repo = "Main";
      rev = "0b81304286de85f2671243ec290a4a2d2399b0a6";
      hash = "sha256-B9uuOyMAseHWgTTGLvm3X1FuxdSP/XQ4vTXRsNP5kZ0=";
    }
    {
      name = "extras";
      owner = "ScoopInstaller";
      repo = "Extras";
      rev = "5e8f6ca5043bdc3e1ddabebfa896bbf1269f2931";
      hash = "sha256-5ihaqTuRAYQ4Qs2TQMhVpoQxjXr0fvzqmvpIcYW51/0=";
    }
  ],
  scoopPackages ? [
    "main/aria2"
    "main/7zip"
    "main/mingit"
    "main/innounp"
    "main/dark"
    "main/gsudo"
  ],
}:
let
  bucketSources = lib.listToAttrs (
    map (bucket: {
      inherit (bucket) name;
      value = fetchFromGitHub {
        inherit (bucket)
          owner
          repo
          rev
          hash
          ;
        leaveDotGit = true;
      };
    }) scoopBuckets
  );

  cachedPackages = map (
    pkgSpec:
    let
      parts = lib.splitString "/" pkgSpec;
      bucketName = lib.head parts;
      app = lib.last parts;
      bucketSrc = bucketSources.${bucketName};
      m = builtins.fromJSON (builtins.readFile "${bucketSrc}/bucket/${app}.json");
      rawUrl = m.architecture."64bit".url or m.url;
      url = if builtins.isList rawUrl then builtins.head rawUrl else rawUrl;
      rawHash = m.architecture."64bit".hash or m.hash;
      hashStr = if builtins.isList rawHash then builtins.head rawHash else rawHash;
      sha256 = lib.removePrefix "sha256:" hashStr;
    in
    {
      inherit app url sha256;
      inherit (m) version;
    }
  ) scoopPackages;
in
runCommand "scoop-dir"
  {
    nativeBuildInputs = [
      git
      zip
    ];
    meta.description = "Hydrate scoop with nix";
  }
  ''
    mkdir --parents $out/buckets $out/cache
    export HOME=$(mktemp --directory)

    ${lib.strings.concatStringsSep "\n" (
      lib.lists.forEach scoopBuckets (bucket: ''
        echo "Hydrating ${bucket.name} bucket..."
        BUCKET_DIR=$out/buckets/${bucket.name}
        cp --archive ${bucketSources.${bucket.name}}/. "$BUCKET_DIR"
        chmod --recursive +w "$BUCKET_DIR"
        cd "$BUCKET_DIR"

        cat << EOF > .git/config
        [core]
          repositoryformatversion = 0
          filemode = false
          bare = false
          logallrefupdates = true
          ignorecase = true
        [remote "origin"]
          url = https://github.com/ScoopInstaller/${bucket.repo}.git
          fetch = +refs/heads/*:refs/remotes/origin/*
        [branch "master"]
          remote = origin
          merge = refs/heads/master
        EOF

        echo "ref: refs/heads/master" > .git/HEAD
        echo "${bucket.rev}" > .git/refs/heads/master
        mkdir --parents .git/refs/remotes/origin
        echo "${bucket.rev}" > .git/refs/remotes/origin/master

        git reset --quiet
        cd -
      '')
    )}

    ${lib.strings.concatStringsSep "\n" (
      lib.lists.forEach cachedPackages (
        pkg:
        let
          src = fetchurl {
            inherit (pkg) sha256 url;
          };
          ext = "." + lib.last (lib.splitString "." pkg.url);
          sha = builtins.substring 0 7 (builtins.hashString "sha256" pkg.url);
          modernName = "${pkg.app}#${pkg.version}#${sha}${ext}";
        in
        ''
          echo "Caching ${pkg.app}..."
          cp --archive ${src} "$out/cache/${modernName}"
          underscored=$(echo "${pkg.url}" | sed 's/[^a-zA-Z0-9.-]/_/g')
          cp --archive ${src} "$out/cache/${pkg.app}#${pkg.version}#$underscored"
        ''
      )
    )}

    cd $out
    zip -r -q scoop-buckets.zip buckets cache
  ''

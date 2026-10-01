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
      hash = "sha256-hBwNQkOEKtlwIZ892ggNT/ejBmyuDlukvEVzNtPUCTY=";
    }
    {
      name = "extras";
      owner = "ScoopInstaller";
      repo = "Extras";
      rev = "5e8f6ca5043bdc3e1ddabebfa896bbf1269f2931";
      hash = "sha256-rnURhwYukuXiHI6bWu+oGbl1RCi+s+wTmTh7UzZMacw=";
    }
  ],
  scoopPackages ? [
    #? 00
    "main/aria2"
    "main/7zip"
    "main/mingit"
    "main/innounp"
    "main/dark"
    "main/gsudo"

    #? 01
    "extras/vcredist-aio"
    "main/winget"

    #? 10
    "main/scoop-search"
    "extras/scoop-completion"
    "main/jq"
    "main/fd"
    "main/bat"
    "main/duf"
    "main/gdu"
    "main/fzf"
    "main/btop"
    "main/neovim"
    "main/zoxide"
    "main/ripgrep"
    "main/eza"
    "main/tlrc"
    "main/yazi"
    "main/starship"
    "main/fastfetch"
    "extras/posh-git"
    "extras/psfzf"
    "main/clink"
    "main/clink-completions"
    "main/lazydocker"
    "main/busybox"
    "main/microsoft-coreutils"
    "main/grep"
    "main/less"
    "main/wget"

    #? 11
    "main/ffmpeg"
    "main/poppler"
    "main/resvg"
    "main/imagemagick"

    #? 12
    "main/gcc"
    "main/make"
    "main/cmake"

    #? 20
    "extras/altsnap"
    "extras/everything"
    "extras/irfanview"
    "extras/notepadplusplus"
    "extras/systeminformer"
    "extras/wiztree"

    #? firefox
    "extras/firefox"
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
      hashAttr =
        if lib.hasPrefix "sha1:" hashStr then
          { sha1 = lib.removePrefix "sha1:" hashStr; }
        else if lib.hasPrefix "sha512:" hashStr then
          { sha512 = lib.removePrefix "sha512:" hashStr; }
        else
          { sha256 = lib.removePrefix "sha256:" hashStr; };
    in
    {
      inherit app url hashAttr;
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
    HOME=$(mktemp --directory)
    export HOME

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
          src = fetchurl (
            {
              inherit (pkg) url;
              curlOptsList =
                lib.optionals (!lib.hasInfix "sourceforge.net" pkg.url && !lib.hasInfix "portableapps.com" pkg.url)
                  [
                    "--referer"
                    pkg.url
                  ];
            }
            // pkg.hashAttr
          );
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

    cd "$out" || exit 1
    zip -r -q scoop-buckets.zip buckets cache
  ''

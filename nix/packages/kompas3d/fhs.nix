{
  lib,
  bash,
  buildFHSEnv,
  fontconfig,
  glibc,
  kdePackages,
  open-sans,
  qt5,
  runCommand,
  writeText,
  kompas ? kdePackages.callPackage ./default.nix { },
}:
let
  locales =
    runCommand "kompas-locales"
      {
        nativeBuildInputs = [ glibc ];
      }
      ''
        mkdir --parents $out/lib/locale/
        localedef --force --no-archive --inputfile=ru_RU --charmap=CP1251 $out/lib/locale/ru_RU.CP1251
        localedef --force --no-archive --inputfile=ru_RU --charmap=UTF-8 $out/lib/locale/ru_RU.UTF-8
        localedef --force --no-archive --inputfile=en_US --charmap=UTF-8 $out/lib/locale/en_US.UTF-8
        localedef --force --no-archive --inputfile=C --charmap=UTF-8 $out/lib/locale/C.UTF-8
        ln --symbolic ru_RU.UTF-8 $out/lib/locale/ru_RU.utf8
        ln --symbolic en_US.UTF-8 $out/lib/locale/en_US.utf8
        ln --symbolic C.UTF-8 $out/lib/locale/C.utf8
      '';
in
buildFHSEnv rec {
  inherit (kompas) version;
  pname =
    if kompas.passthru.edition == "viewer" then
      "kompas3d-viewer-fhs"
    else if kompas.passthru.edition == "home" then
      "kompas3d-home-fhs"
    else if kompas.passthru.edition == "study" then
      "kompas3d-study-fhs"
    else
      "kompas3d-fhs";
  extraBuildCommands = ''
    mkdir --parents $out/usr/local/
  '';
  extraBwrapArgs = [
    "--tmpfs /usr/local"
    "--bind-try /etc/nixos/ /etc/nixos/"
  ];
  # symlink shared assets, including icons and desktop entries
  extraInstallCommands = ''
    ln --symbolic "${kompas}/share" "$out/"
    ln --symbolic "$out/bin/${pname}" "$out/bin/${kompas.meta.mainProgram}"
    ${lib.optionalString (kompas.passthru.edition == "study") ''
      ln --symbolic "$out/bin/${pname}" "$out/bin/kompas3d-fhs"
    ''}
  '';
  profile = ''
    export LOCPATH=/usr/lib/locale
    export LC_ALL=ru_RU.UTF-8
    export LANG=ru_RU.UTF-8
    (
      custom_font_dir="/usr/local/share/fonts"
      if [ -d "$custom_font_dir" ]; then
        echo "Font directory $custom_font_dir already exists, skipping font linking"
        return 0
      fi
      echo "Start font linking inside FHS env cause kompas only checks /usr/{,local/}share/fonts/ dirs"
      mkdir --parents "$custom_font_dir"
      for font in $(${fontconfig}/bin/fc-list --format "%{file}\n" | sort --unique | awk --field-separator=/ '{if (!seen[$NF]++) print $0}'); do
        [ -L "$font" ] && font=$(readlink --canonicalize "$font")
        relpath=$(dirname $(echo $font | sed 's|.*/share/fonts/||'))
        target="$custom_font_dir/$relpath/"
        mkdir --parents "$target"
        ln --symbolic "$font" "$target"
      done
    )
  '';
  # "${lib.getExe kompas}"
  runScript = "${lib.getExe bash} ${writeText "kompas-wrapper" ''
    export LOCPATH=/usr/lib/locale
    export LC_ALL=ru_RU.UTF-8
    export LANG=ru_RU.UTF-8
    export QT_QPA_PLATFORM=xcb
    export QT_STYLE_OVERRIDE=Fusion
    # export QT_STYLE_OVERRIDE=Windows
    cd /opt/ascon/${kompas.passthru.appDir}/Bin/
    exec ./${kompas.passthru.binary} "$@"
  ''}";
  targetPkgs = _pkgs: [
    kompas
    locales
    open-sans
    qt5.qtbase
  ];
}

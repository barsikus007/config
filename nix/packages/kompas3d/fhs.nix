{ pkgs, ... }:
with pkgs;
let
  kompas = (callPackage ./default.nix { });
in
buildFHSEnv {
  pname = "kompas3d-fhs";
  inherit (kompas) version;

  targetPkgs = pkgs: [
    kompas
    open-sans
  ];
  extraBuildCommands = ''
    mkdir -p $out/usr/local/
  '';
  extraBwrapArgs = [
    "--tmpfs /usr/local"
    "--bind-try /etc/nixos/ /etc/nixos/"
  ];

  # symlink shared assets, including icons and desktop entries
  extraInstallCommands = ''
    ln -s "${kompas}/share" "$out/"
    ln -s "$out/bin/${pname}" "$out/bin/${kompas.meta.mainProgram}"
  '';

  profile = ''
    (
      custom_font_dir="/usr/local/share/fonts"
      if [ -d "$custom_font_dir" ]; then
        echo "Font directory $custom_font_dir already exists, skipping font linking"
        return 0
      fi
      echo "Start font linking inside FHS env cause kompas only checks /usr/{,local/}share/fonts/ dirs"
      mkdir -p "$custom_font_dir"
      for font in $(${fontconfig}/bin/fc-list -f "%{file}\n" | sort -u | awk -F/ '{if (!seen[$NF]++) print $0}'); do
        [ -L "$font" ] && font=$(readlink -f "$font")
        relpath=$(dirname $(echo $font | sed 's|.*/share/fonts/||'))
        target="$custom_font_dir/$relpath/"
        mkdir -p "$target"
        ln -s "$font" "$target"
      done
    )
  '';
  # "${kompas}/bin/${kompas.meta.mainProgram}"
  runScript = "${bash}/bin/bash ${writeText "kompas-wrapper" ''
    export QT_QPA_PLATFORM=xcb
    export QT_STYLE_OVERRIDE=Fusion
    # export QT_STYLE_OVERRIDE=Windows
    cd /opt/ascon/kompas3d-v24/Bin/
    ./kKompas
  ''}";
}

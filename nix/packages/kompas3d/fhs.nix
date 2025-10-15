{ pkgs, ... }:
with pkgs;
buildFHSEnv {
  name = "kompas3d-fhs";
  targetPkgs = pkgs: [
    (callPackage ./default.nix { })
    open-sans
  ];
  extraBuildCommands = ''
    mkdir -p $out/usr/local/
  '';
  extraBwrapArgs = [
    "--tmpfs"
    "/usr/local"
  ];
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
  # runScript = "kompas-v24";
  # runScript = "QT_QPA_PLATFORM=xcb kompas-v24";
  # runScript = "QT_STYLE_OVERRIDE=Windows kompas-v24";
  # runScript = "QT_STYLE_OVERRIDE=Fusion kompas-v24";
  runScript = "env QT_QPA_PLATFORM=xcb QT_STYLE_OVERRIDE=Fusion kompas-v24";
}

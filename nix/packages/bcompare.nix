{
  lib,
  autoPatchelfHook,
  bzip2,
  cairo,
  fetchurl,
  gdk-pixbuf,
  glibc,
  pango,
  gtk3,
  python3,
  gobject-introspection,
  kcoreaddons,
  ki18n,
  kio,
  kservice,
  poppler,
  poppler_utils,
  gvfs,
  wrapQtAppsHook,
  qtbase,
  stdenv,
  runtimeShell,
  unzip,
}:

# thx https://github.com/erahhal/nixcfg/blob/93d251e25f6901e585f0941d2accbd6e315f778b/pkgs/bcompare-beta/default.nix
# og https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/version-management/bcompare/default.nix

let
  pname = "bcompare";
  version = "5.1.0.31016";

  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://www.scootersoftware.com/files/${pname}-${version}_amd64.deb";
      sha256 = "sha256-LpvxeOfQGAFs1CshRxfrYuOK/4d7QiAWXojsJMtVFy0=";
    };

    # x86_64-darwin = fetchurl {
    #   url = "https://www.scootersoftware.com/BCompareOSX-${version}.zip";
    #   sha256 = "sha256-hUzJfUgfCuvB6ADHbsgmEXXgntm01hPnfSjwl7jI70c=";
    # };

    # aarch64-darwin = srcs.x86_64-darwin;
  };

  src = srcs.${stdenv.hostPlatform.system} or throwSystem;

  linux =
    let
      python = (
        python3.withPackages (
          pp: with pp; [
            pygobject3
          ]
        )
      );
    in
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;
    unpackPhase = ''
      ar x $src
      tar xfz data.tar.gz
    '';

    installPhase = ''
      mkdir -p $out/{bin,lib,share}

      cp -R usr/{bin,lib,share} $out/

      # Remove library that refuses to be autoPatchelf'ed
      rm $out/lib/beyondcompare/ext/bcompare_ext_kde.amd64.so
      rm $out/lib/beyondcompare/ext/bcompare_ext_kde6.amd64.so

      substituteInPlace $out/bin/${pname} \
        --replace "/usr/lib/beyondcompare" "$out/lib/beyondcompare" \
        --replace "ldd" "${glibc.bin}/bin/ldd" \
        --replace "/bin/bash" "${runtimeShell}"

      # Create symlink bzip2 library
      ln -s ${bzip2.out}/lib/libbz2.so.1 $out/lib/beyondcompare/libbz2.so.1.0


      substituteInPlace $out/lib/beyondcompare/bcmount.sh \
        --replace "python3" "${python.interpreter}"

      wrapQtApp $out/bin/bcompare
    '';

    #? sorry, I can't buy this software right now (and trial don't work)
    #? https://gist.github.com/rise-worlds/5a5917780663aada8028f96b15057a67?permalink_comment_id=5168755#gistcomment-5168755
    postFixup = ''
      sed -i "s/AlPAc7Np1/AlPAc7Npn/g" $out/lib/beyondcompare/BCompare
    '';

    nativeBuildInputs = [
      autoPatchelfHook
      wrapQtAppsHook
      gobject-introspection
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      gtk3
      python
      pango
      cairo
      kio
      kservice
      ki18n
      kcoreaddons
      gdk-pixbuf
      bzip2

      qtbase
      poppler
      poppler_utils
      gvfs
      bzip2
    ];

    dontBuild = true;
    dontConfigure = true;
    dontWrapQtApps = false;
  };

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;
    nativeBuildInputs = [ unzip ];

    installPhase = ''
      mkdir -p $out/Applications/BCompare.app
      cp -R . $out/Applications/BCompare.app
    '';
  };

  meta = with lib; {
    description = "GUI application that allows to quickly and easily compare files and folders";
    longDescription = ''
      Beyond Compare is focused. Beyond Compare allows you to quickly and easily compare your files and folders.
      By using simple, powerful commands you can focus on the differences you're interested in and ignore those you're not.
      You can then merge the changes, synchronize your files, and generate reports for your records.
    '';
    homepage = "https://www.scootersoftware.com";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.free;
    maintainers = with maintainers; [
      ktor
      arkivm
    ];
    platforms = builtins.attrNames srcs;
    mainProgram = "bcompare";
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux

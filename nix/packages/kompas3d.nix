{
  stdenv,
  lib,

  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,

  qt6,
  xorg,
  xcb-util-cursor,
  libgcc,
  util-linux,
  llvmPackages,
  cups,
  libGLU,
  tinyxml,
  gtk2,
}:

let
  version = "24.1.0.64";
  pkgsList = [
    {
      name = "ascon-kompas3d-v24-full";
      hash = "sha256-iaSeDzShGJdwtsUL+BtzlvAYIIadxqpIr3kue5AZk/0=";
    }
    {
      name = "ascon-kompas-common-v24";
      hash = "sha256-e1bd2FN5Xbuwq2jvfxU230RpBRSur/WhkJ4jPpQNJwE=";
    }
    {
      name = "ascon-kompas3d-v24";
      hash = "sha256-M//vJ+lfRKj86cYW0ZUXTlg3rnBr0BBZ1qJJn5fZuNQ=";
    }
    {
      name = "ascon-kompas-graphic-v24";
      hash = "sha256-bOX0T64RZHxqGpGfN8U2hHA2kWxeoy+xIiz+gjqreJE=";
    }
    {
      name = "ascon-kompas-plugins-v24";
      hash = "sha256-V6hVRkv8KgDq2P0x+IV0Zowngy6iYaDULwpr6tAHVFI=";
    }
    {
      name = "ascon-kompas-nesting-v24";
      hash = "sha256-SiR8zTHiJD2IB5WdVvGpC0BEtrDbXJLjjTC8xY5N1XY=";
    }
    {
      name = "ascon-kompas-servicetools-v24";
      hash = "sha256-G3+Sqq5WJ7Xgdb0xGulFczPqGPsVGlghhCrNj68K1t8=";
    }
    {
      name = "ascon-kompas-featurekompas-v24";
      hash = "sha256-FSM848+wTOA7Ol84LPzFLI6WP+eY7taSKMRFUT5NROE=";
    }
    {
      name = "ascon-kompas-sdk-v24";
      hash = "sha256-D14LgHtqe+BsIBeCkaJdyrNj2UxyvU1WL/bhcTW7QGo=";
    }
    {
      name = "ascon-kompas-libsamples-v24";
      hash = "sha256-+pSovwz3i9eo3jfudiIOVJU78Rb6Dqomil6vWPvKD28=";
    }
    {
      name = "ascon-kompas-coupling-v24";
      hash = "sha256-BVbcZHo8aDgHxopkxk0SlFBRckjw5+HrPW3BURm5vjA=";
    }
    {
      name = "ascon-kompas-help-v24";
      hash = "sha256-Ws4RCDlGKfS0bNrct5i4pLOtkeiPaYflRmLbGHVNbXE=";
    }
    {
      name = "ascon-kompas-checker-v24";
      hash = "sha256-JuGhlKmlfZbDxI/2uzdSK/wH6BBUSKsS9Wxp9/6U2uE=";
    }
    {
      name = "ascon-kompas-dimchain-v24";
      hash = "sha256-G2YvDq6IIuRG6NOCGbjQC31lZFNXjVdvEusxGnzJs8Q=";
    }
  ];

  fetchDebs =
    package:
    fetchurl {
      url = "https://repo.ascon.ru/beta/deb/pool/main/a/${package.name}/${package.name}_${version}_amd64.deb";
      hash = package.hash;
    };

  srcs = (map fetchDebs pkgsList) ++ [
    (fetchurl {
      url = "https://repo.ascon.ru/beta/deb/pool/main/a/ascon-kompas-fonts/ascon-kompas-fonts_1.0.0.4_amd64.deb";
      hash = "sha256-lNPCNrkoz62+LCka7A6cj1Lsgj5jFVfk9AgAqjU0s7w=";
    })
    (fetchurl {
      url = "https://repo.ascon.ru/beta/deb/pool/main/a/ascon/ascon-polynom-library-23.3-23.3.0.25091905-amd64.deb";
      hash = "sha256-TBQQGnignLxUn4Tadzv9a6xa1UarjtMW1MD4wBGq3Bs=";
    })
  ];

in
stdenv.mkDerivation {
  pname = "kompas3d-v24-full";
  inherit version srcs;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  autoPatchelfIgnoreMissingDeps = [ "*.tx" "*.txv" "liboless.so" ];

  propagatedBuildInputs = [
    # icu is needed for dotnet based Bin/Ascon.HelpCall, but idk how to pass it
    gtk2
    libgcc.lib
    qt6.full
    util-linux.lib
    cups
    libGLU
    tinyxml
    xcb-util-cursor
    xorg.libSM
    xorg.libXxf86vm
    xorg.libXv
    xorg.libXres
    xorg.libXpm
    xorg.libXmu
    xorg.libxkbfile
    xorg.libXinerama
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXcursor
    xorg.libXcomposite
    xorg.libXaw
    xorg.libXt
    xorg.libXtst
    xorg.libICE
    xorg.libfontenc
    xorg.libxcb
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.libXScrnSaver
    xorg.libXi
    xorg.xcbutil
    xorg.xcbutilwm
    xorg.xcbutilrenderutil
    xorg.xcbutilkeysyms
    xorg.xcbutilimage
    xorg.libXdmcp
    xorg.libXau
    llvmPackages.libcxx
    llvmPackages.libunwind
    llvmPackages.openmp
  ];

  # TODO: шрифты /usr/{,local/}share/fonts; мбграфика; icu для дотнета
  # readlink -f $(which kompas-v24)
  # sudo ln -s /nix/store/paththatwillbeoutputedabove-kompas3d-v24-full-24.1.0.64/opt/ascon /opt/ascon
  # https://wiki.nixos.org/wiki/Packaging/Binaries#Wrong_file_paths
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt,share}/
    cp -R {etc,opt} $out/
    cp -R usr/{bin,share} $out/

    basepath=$out/opt/ascon/kompas3d-v24

    ln -s $basepath/Bin/kKompas $out/bin/kompas-v24
    ln -s $basepath/License/kactivation $out/bin/kompas-kactivation-v24
    ln -s $out/opt/ascon/PolynomLibrary $basepath/Libs/PolynomLibrary

    mv $out/share/applications/flystartmenu/kompas3d-24/* $out/share/applications/
    rm -rf $out/share/applications/flystartmenu
    substituteInPlace $out/share/applications/* \
      --replace-quiet "/opt/ascon/kompas3d-v24" "$basepath"

    examplesfile=$basepath/Bin/UIConfig/Examples.xml
    iconv -f UTF-16LE -t UTF-8 $examplesfile -o $examplesfile
    substituteInPlace $examplesfile \
      --replace-fail "..\Samples" "$out\opt\ascon\kompas3d-v24\Samples"
    iconv -f UTF-8 -t UTF-16LE $examplesfile -o $examplesfile

    runHook postInstall
  '';

  dontBuild = true;

  meta = with lib; {
    description = "КОМПАС-3D для машиностроения и приборостроения";
    longDescription = ''
      КОМПАС-3D для машиностроения и приборостроения
        Данный пакет предназначен для установки КОМПАС-3D для машиностроения и приборостроения в составе:
        * КОМПАС-График
        * КОМПАС-3D
        * Локальная справка для КОМПАС-3D
        * Шрифты чертежные
        * Средства разработки приложений
        * Каталог: Муфты
        * Размерные цепи
        * Сервисные инструменты
        * Проверка документов
        * Распознавание 3D-моделей
        * Раскрой
        * Примеры библиотек фрагментов и моделей
        * Стандартные Изделия для КОМПАС
    '';
    homepage = "https://ascon.ru/products/kompas-3d/";
    platforms = platforms.linux;
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ barsikus007 ];
    mainProgram = "kompas-v24";
  };
}

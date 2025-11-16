{
  stdenv,
  lib,

  fetchurl,
  dpkg,
  autoPatchelfHook,

  xorg,
  xcb-util-cursor,
  libdrm,
  libgcc,
  util-linux,
  llvmPackages,
  cups,
  libGLU,
  tinyxml,
  gtk2,
}:

let
  version = "24.1.0.100";
  pkgsList = [
    {
      name = "ascon-kompas3d-v24-full";
      hash = "sha256-EkSbvM8u+mI/TDbds31rojdquNosLQOwgFZc1Mt2a2Q=";
    }
    {
      name = "ascon-kompas-common-v24";
      hash = "sha256-Ml8OjpiIz2VVUpMfImmE4dTdh8RS97xnXEa/gyps3sg=";
    }
    {
      name = "ascon-kompas3d-v24";
      hash = "sha256-RxYkSTyNjLFJzKtbzpn5ep8uuyUMW5TkBI3KUdn3u+o=";
    }
    {
      name = "ascon-kompas-graphic-v24";
      hash = "sha256-8FX1x2Pv6YEm9HvK2KJSVFF30ygrlWX+0bhnI7bzmGo=";
    }
    {
      name = "ascon-kompas-plugins-v24";
      hash = "sha256-W5lrFmKOKeH295pQ6HEl2bL+LVM7h9AM8nogJSlgvPo=";
    }
    {
      name = "ascon-kompas-nesting-v24";
      hash = "sha256-PRF9g+hCNqxTc5gED4m7pxgWKn1TAZvRfyyf5ZHZNoo=";
    }
    {
      name = "ascon-kompas-servicetools-v24";
      hash = "sha256-ZwgAD/4TM4mCDaFXFKKNUrgG7e9P9B1djvn58UmFJh4=";
    }
    {
      name = "ascon-kompas-featurekompas-v24";
      hash = "sha256-ysfWiAMZ9EzgPj5fFRmbM5Obrja728T4wWtTA/kP0uk=";
    }
    {
      name = "ascon-kompas-sdk-v24";
      hash = "sha256-5OdNfT/AdrHWds9NgPBFj25ng1+uoRHawyu4sdZ3UlY=";
    }
    {
      name = "ascon-kompas-libsamples-v24";
      hash = "sha256-hge1NZy06aQWWkV4ol4676At3TxPCXGrwFxT/8673m4=";
    }
    {
      name = "ascon-kompas-coupling-v24";
      hash = "sha256-uiWCSLxBn0CAa/x8BW0QoM7z8G3HKSmp+esqFHKGVk0=";
    }
    {
      name = "ascon-kompas-help-v24";
      hash = "sha256-qarIDgemCClvK6ZYbbE0ISGj8C036gs4CllE2EESieQ=";
    }
    {
      name = "ascon-kompas-checker-v24";
      hash = "sha256-WRbWkXW2DZEWsNZC6fPknUSPfpVskRfivxMSvtMVKPo=";
    }
    {
      name = "ascon-kompas-dimchain-v24";
      hash = "sha256-nHvtzD3gXzsVRFwIjBgmxHC90lL+XbCz1c0/ctYfSnE=";
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
  ];

  autoPatchelfIgnoreMissingDeps = [
    "*.tx"
    "*.txv"
    "liboless.so"
  ];

  propagatedBuildInputs = [
    gtk2
    libgcc.lib
    # qt6.full
    util-linux.lib
    cups
    libGLU
    tinyxml
    libdrm
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
    # icu  #? is needed for dotnet based Bin/Ascon.HelpCall, but idk how to pass it
  ];

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
    substituteInPlace $out/share/applications/*help* \
      --replace-fail "$basepath" "env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 $basepath"

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
    platforms = with platforms; lists.intersectLists x86_64 linux;
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ barsikus007 ];
    mainProgram = "kompas-v24";
  };
}

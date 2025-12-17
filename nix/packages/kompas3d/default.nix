{
  stdenv,
  lib,

  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapQtAppsHook,

  qt3d,

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
  version = "24.1.0.161";
  pkgsList = [
    {
      name = "ascon-kompas3d-v24-full";
      hash = "sha256-KhBf0K450J3donQB7OmbHuPUmNREcCWJdFlhi6dkXyo=";
    }
    {
      name = "ascon-kompas3d-v24";
      hash = "sha256-aFJ5OT1ZtT6a9IGURMtIWoHYSCZG4c8SlXNLmyLg6Zc=";
    }
    {
      name = "ascon-kompas-graphic-v24";
      hash = "sha256-5ebowbW/HxnZfnC6uUizBsQKD+NCu9+WgwcGz8Oop4I=";
    }
    {
      name = "ascon-kompas-plugins-v24";
      hash = "sha256-A90aR0AIJDSdu6kXq70g/kIm1w7QUnl/wOOgwwnUdrY=";
    }
    {
      name = "ascon-kompas-nesting-v24";
      hash = "sha256-/LXNk9k2MmDvgnf4eGqrXCGnswdmeDyBvrlAcVMgZY8=";
    }
    {
      name = "ascon-kompas-servicetools-v24";
      hash = "sha256-QiEqVyllq5ahZsE+liUWoCqOqrqL4Tpgc6MXPCeS0fo=";
    }
    {
      name = "ascon-kompas-featurekompas-v24";
      hash = "sha256-zuWsok3h5deOEqJ8Na4ruaKh8rjVPfAN4yj7RlNSiQA=";
    }
    {
      name = "ascon-kompas-sdk-v24";
      hash = "sha256-z0bohENrSBk4LDPK+cC3YkYARxvwdpEJMZdVuf1oAPA=";
    }
    {
      name = "ascon-kompas-libsamples-v24";
      hash = "sha256-wZfda5t8aaH2IlHByZrKa7lDfeqWK483FxQnaoXhARk=";
    }
    {
      name = "ascon-kompas-coupling-v24";
      hash = "sha256-lptq6iZA0Ij09VkvwsIcAqAuJJfSfpn8/Vqn8AaJhtU=";
    }
    {
      name = "ascon-kompas-help-v24";
      hash = "sha256-nmFqmsPx6g0+4ptFnOJ6AtVoSVtZWEGmU88qhQl9XR8=";
    }
    {
      name = "ascon-kompas-checker-v24";
      hash = "sha256-z+huhrrEvgA50G0UJ7Cd7q0pMAJtYoTk2BHyEZepzXU=";
    }
    {
      name = "ascon-kompas-dimchain-v24";
      hash = "sha256-EtY1KLWWFWTogY0QnS/E4x+76FaUohWBk860CJrSuo0=";
    }
  ];

  fetchDebs =
    package:
    fetchurl {
      url = "https://repo.ascon.ru/stable/deb/pool/main/a/${package.name}/${package.name}_${version}_amd64.deb";
      hash = package.hash;
    };

  srcs = (map fetchDebs pkgsList) ++ [
    (fetchurl {
      url = "https://repo.ascon.ru/stable/deb/pool/main/a/ascon-kompas-common/ascon-kompas-common_1.0.0.3_amd64.deb";
      hash = "sha256-fYGTd2WNrQBSXDvn5g/yHM8WTXkALNsnGPd9dxUNgM4=";
    })
    (fetchurl {
      url = "https://repo.ascon.ru/stable/deb/pool/main/a/ascon-kompas-fonts/ascon-kompas-fonts_1.0.0.7_amd64.deb";
      hash = "sha256-iQKgDSzyd3fRBcZzl4IbkCn9Z0z+xsCRRhW+lbo9cyo=";
    })
    # ascon-kompas3d-viewer-help-v24/
    # ascon-kompas3d-viewer-v24/
    # ascon-kompas3d-viewer-v24-full/
    (fetchurl {
      url = "https://repo.ascon.ru/stable/deb/pool/main/a/ascon/ascon-polynom-library-23.3-23.3.0.25101312-amd64.deb";
      hash = "sha256-IIfFSfZ2+HTf0diA7+6BcvGzIgDbwDmUq1ruAqLaB20=";
    })
    # ascon-cas-23.3-23.3.0.25092913-amd64.deb
    # ascon-commons-23.3-23.3.0.25092914-amd64.deb
    # ascon-csc-agent-5.1-5.1.0.43.deb
    # ascon-csc-console-5.1-5.1.0.43.deb
    # ascon-csc-monitor-5.1-5.1.0.43.deb
    # ascon-loodsman-23.3-23.3.1.25101616-amd64.deb
    # ascon-loodsman-appserver-23.3-23.3.1.25101616-amd64.deb
    # ascon-loodsman-file-archive-service-23.3-23.3.1.25101616-amd64.deb
    # ascon-loodsman-load-balancer-23.3-23.3.1.25101616-amd64.deb
    # ascon-loodsman-notify-23.3-23.3.1.25101616-amd64.deb
    # ascon-polynom-appserver-23.3-23.3.0.25081118-amd64.deb
    # ascon-polynom-database-23.3-23.3.0.25080512-amd64.deb
    #? ascon-polynom-library-23.3-23.3.0.25101312-amd64.deb
    # ascon-polynom-migration-23.3-23.3.0.25081118-amd64.deb
    # ascon-polynom-webserver-23.3-23.3.0.25081118-amd64.deb
  ];

in
stdenv.mkDerivation {
  pname = "kompas3d-v24-full";
  inherit version srcs;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapQtAppsHook
  ];

  autoPatchelfIgnoreMissingDeps = [
    "*.tx"
    "*.txv"
    "liboless.so"
  ];

  propagatedBuildInputs = [
    gtk2
    libgcc.lib
    qt3d
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

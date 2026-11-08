{
  lib,
  autoPatchelfHook,
  cups,
  dpkg,
  fetchurl,
  gtk2,
  libGLU,
  libICE,
  libSM,
  libXScrnSaver,
  libdrm,
  libfontenc,
  libgcc,
  libtiff,
  libwebp,
  libx11,
  libxau,
  libxaw,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxdmcp,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxkbfile,
  libxmu,
  libxpm,
  libxrandr,
  libxrender,
  libxres,
  libxt,
  libxtst,
  libxv,
  libxxf86vm,
  llvmPackages,
  qt3d,
  stdenv,
  tinyxml,
  util-linux,
  wrapQtAppsHook,
  xcb-util-cursor,
  xcbutil,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  xcbutilwm,
  edition ? "study",
  withPolynom ? true,
}:

let
  version = "25.0.5.2780";
  major = lib.versions.major version;
  v = "-v${major}";

  appDir = if edition == "viewer" then "kompas3d-viewer${v}" else "kompas3d${v}";

  binary =
    if edition == "viewer" then
      "kViewer"
    else if edition == "home" then
      "kHome"
    else if edition == "study" then
      "kStudy"
    else
      "kKompas";

  mainProgram =
    if edition == "viewer" then
      "kompas3d-viewer${v}"
    else if edition == "home" then
      "kompas-home${v}"
    else if edition == "study" then
      "kompas-study${v}"
    else
      "kompas${v}";

  pname =
    if edition == "viewer" then
      "kompas3d-viewer${v}-full"
    else if edition == "home" then
      "kompas3d-home${v}-full"
    else if edition == "study" then
      "kompas3d-study${v}-full"
    else
      "kompas3d${v}-full";

  editionDescription =
    if edition == "viewer" then
      "Просмотр и печать (КОМПАС-3D Viewer)"
    else if edition == "home" then
      "Домашняя версия"
    else if edition == "study" then
      "Учебная версия"
    else
      "Профессиональная версия";

  fetchDeb =
    {
      hash,
      name,
      filename ? "${name}_${ver}_amd64.deb",
      poolPath ? "main/a/${name}",
      repo ? "stable",
      ver ? version,
    }:
    fetchurl {
      inherit hash;
      url = "https://repo.ascon.ru/${repo}/deb/pool/${poolPath}/${filename}";
    };

  mkAscon = name: hash: {
    inherit hash;
    name = "ascon-kompas-${name}${v}";
  };

  viewerPkgs = [
    {
      name = "ascon-kompas3d-viewer${v}-full";
      hash = "sha256-UtQnBbOR0GnHurPajEUi0OmGC932xFazO7gz6qkJ8qA=";
    }
    {
      name = "ascon-kompas3d-viewer${v}";
      hash = "sha256-KIsDsRo7NdgHr8GzGzno/nnaOoWpZH4iX//vdq5Fzxs=";
    }
    {
      name = "ascon-kompas3d-viewer-help${v}";
      hash = "sha256-4S1kaOMJLOpnbCs01rOkQFrGc7Oga0TcaIVBR8pgBUo=";
    }
    {
      name = "ascon-polynom-parts-24.0";
      filename = "ascon-polynom-parts-24.0-24.0.0.26031317-amd64.deb";
      hash = "sha256-pSWSI8pnLrklkxjsz55KUbLkpgXF8lNnC4TiKOTYf6s=";
      poolPath = "main/a/ascon";
      ver = "24.0.0.26031317";
    }
  ];

  editionPkgs =
    if edition == "study" then
      [
        {
          name = "ascon-kompas3d-study${v}-full";
          hash = "sha256-ikJJVQDYaOl3zDPzFT+6s+AHVXALF5Jkw+Iy49lKrOg=";
          repo = "personal";
        }
        {
          name = "ascon-kompas-study${v}";
          hash = "sha256-4UwjUHgvnuSF73m1NNuooLt3T5FzGLG+0WZqWAZKcBU=";
          repo = "personal";
        }
      ]
    else if edition == "home" then
      [
        {
          name = "ascon-kompas3d-home${v}-full";
          hash = "sha256-ko1aGHP63aAod7XkyE6oAEG6J80lJRBnCsARRE2hNms=";
          repo = "personal";
        }
        {
          name = "ascon-kompas-home${v}";
          hash = "sha256-fCWp3LogVJN8w62anFb4iZydTC2ZrxWDaGfR88+XB9w=";
          repo = "personal";
        }
        {
          name = "ascon-kompas-tutorials-3dprint${v}";
          hash = "sha256-yOqPOa6mlrf0tPpaj0NPCjnF0LWApnmeWomDo24CqXA=";
          repo = "personal";
        }
        {
          name = "ascon-kompas-kactivation${v}";
          hash = "sha256-hEmeUx4qiBRBLSFGsS9vekiM6ataKPYi8gRHJBUMpJI=";
          ver = "4.3.9.134-1";
        }
      ]
    else
      [
        {
          name = "ascon-kompas3d${v}-full";
          hash = "sha256-Gwse52x/Mo9J6AhTxpecW4H8MC0r83ccqCsoQyeOdWM=";
        }
        {
          name = "ascon-kompas${v}";
          hash = "sha256-+lelhiZDqujp3oBl3mC1CjzvvOuvmBYCWWHBaV8MVP8=";
        }
        {
          name = "ascon-kompas-kactivation${v}";
          hash = "sha256-hEmeUx4qiBRBLSFGsS9vekiM6ataKPYi8gRHJBUMpJI=";
          ver = "4.3.9.134-1";
        }
        (mkAscon "composite3d" "sha256-1Obc9wggibx3yI4tmthBqx/P7X0j1KleYTThjjIt5LQ=")
        (mkAscon "kdpackagebuilder" "sha256-C2LignrYaIyyBCqAeF7M8gepsP6Shj8P/61MbSYXTPU=")
      ];

  commonPkgs = [
    {
      name = "ascon-kompas3d${v}";
      hash = "sha256-ERhkYRWhzvpzP39/d121+POCN54cujlevalLN+F3jOo=";
    }
    (mkAscon "graphic" "sha256-oFD2e5y5UiMgyBvg1S/ZTq7gH9gOwLMDKk/D5a7Dd/E=")
    (mkAscon "plugins" "sha256-IydpS8ocUadXitTN4/eFf/v8LyiiQCNN24xJ7ibDMtg=")
    (mkAscon "help" "sha256-LFAHlGZV6tYQzAXWIR7GFhfI4TWKMghK6Kzna/jvQ+4=")
    (mkAscon "sdk" "sha256-L2nEl+bKrVF67tZXV/5UCF9BMnwSauvMdzcd/TIQsMw=")
    (mkAscon "coupling" "sha256-bSTDCYH85RUPk1mz635bacoAYA23PU2zFqq2bDGQfAo=")
    (mkAscon "dimchain" "sha256-H4iEUaChH0xBcjA2PDXTc95onxz20Z38j3diTXWxTxE=")
    (mkAscon "servicetools" "sha256-P+zTAxIU2MkVTeStPDxOT5ttoYm3WQCTMLg8ObKziOo=")
    (mkAscon "checker" "sha256-6AvPxREyeOXAi50gYcrYh82bxCMS6hwEjgWaV24OAj0=")
    (mkAscon "featurekompas" "sha256-tb6uW6lsEchmdkdXSpr7Wo+ijf9y7or7X7DCeodwJYA=")
    (mkAscon "nesting" "sha256-bMkb2dNHuXPkdeeG9tJoj8TrXZKQZEZqYxJcT6EekmM=")
    (mkAscon "libsamples" "sha256-DqHBHpZnD0gmajuu9Z0Fc4jV2ncKGDN8WG3fowD+yPc=")
    (mkAscon "easysteel" "sha256-xVeKCK5gdXPV3KnqU3Ei0DRXzV6g6GuuX4fSfHB4qoo=")
    (mkAscon "pipeline" "sha256-T07YH6WnqqiMEj6DTcBeZPr3FzEMTIYgqCGDRU1nWfk=")
    (mkAscon "trays" "sha256-GaG25ibsyE8ZmlFNACEtOC9DWBkr9gin9nCmTfAx3oA=")
    (mkAscon "ventilation" "sha256-3K+nm6fvebH0mjGWHvymncs2cKfwnwgj1VkXWh/0SFs=")
    (mkAscon "coating3d" "sha256-KN1BMQJWgR3eAwdOrugd3JHBZ/mD2DEugyFgB9kG5t4=")
    (mkAscon "splitconnection3d" "sha256-41j6WISKLn41n/Zi3aE+QWgJD26SowMHGThUvly6HeQ=")
    (mkAscon "cable" "sha256-SWEQB2p984cEk1uYzPFGqq8cMcDXdouPi7+Xy23DsWc=")
    (mkAscon "ergonomics" "sha256-s8yT1bHuDZYNh/IKcRIygApJXx1lAj0FK9l/ndsaGkA=")
    (mkAscon "diecore" "sha256-03o0To9cVTKqXERq9jTBFH1Ay+ZLAeqUJDUb8rWNf/A=")
    (mkAscon "mouldcore" "sha256-I+TNYJ0aVRPYeRvlmLkm5E5mf3qQ5+v1kjvQUqpXvIw=")
    (mkAscon "weldconnect" "sha256-vTCIvLU8mQyn45VqlxLB5HE51TwTLvKfTL2ssdzfAFQ=")
    (mkAscon "sdf3dapp" "sha256-NaR/rG1qidgG7CLoZm34e9D4G1RgnACRTSxAnpYwnxI=")
    (mkAscon "tutorials" "sha256-1AwLXglSEFWSek1pUJxIhMg7faEVIua9KT2r4Rx1vx0=")
    {
      name = "ascon-kompas-unwrap${v}";
      hash = "sha256-tEN/tjDEnCrYfKvFWaJeiq+nm/c3cfYW3DHwnsk+skY=";
      ver = "25.0.0.16";
    }
    {
      name = "tesis-kompas-kompasflow${v}";
      hash = "sha256-NsLfPN9CsctnimwrwmwNrxj+qRKBzXNxSWUBBLFv+mI=";
      poolPath = "main/t/tesis-kompas-kompasflow${v}";
      ver = "25.0.0.7-0";
    }
  ];

  extraSrcs = [
    (fetchDeb {
      name = "ascon-kompas-common";
      hash = "sha256-g35+GULLyy2iuQrtoRBPDNA4C/SkhXaegF67EQWUp2c=";
      ver = "1.0.0.7";
    })
    (fetchDeb {
      name = "ascon-kompas-fonts";
      hash = "sha256-VU9tOgRrvQG2sQDGVJpjyOjHj0nJoMrFEjbrR3JO7V8=";
      ver = "1.0.0.8";
    })
    (fetchDeb {
      name = "ascon-helpserver";
      hash = "sha256-mA0IaW80P/6VkcIV7Ym32syLGcOLGpwW2wFM5PaSrlc=";
      ver = "0.8.1.11";
    })
  ]
  ++ lib.optional (edition != "viewer" && withPolynom) (fetchDeb {
    name = "ascon-polynom-library-24.0";
    filename = "ascon-polynom-library-24.0-24.0.0.26061516-amd64.deb";
    hash = "sha256-d6H5BQEsH0m0fJFear+BOA68/3L/IqGv46aKzVCEIww=";
    poolPath = "main/a/ascon";
    ver = "24.0.0.26061516";
  });

  srcs =
    (map fetchDeb (if edition == "viewer" then viewerPkgs else editionPkgs ++ commonPkgs)) ++ extraSrcs;

in
stdenv.mkDerivation {
  inherit version srcs pname;
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapQtAppsHook
  ];
  propagatedBuildInputs = [
    gtk2
    libgcc.lib
    libtiff
    libwebp
    qt3d
    util-linux.lib
    cups
    libGLU
    tinyxml
    libdrm
    xcb-util-cursor
    libSM
    libxxf86vm
    libxv
    libxres
    libxpm
    libxmu
    libxkbfile
    libxinerama
    libxdamage
    libxfixes
    libxcursor
    libxcomposite
    libxaw
    libxt
    libxtst
    libICE
    libfontenc
    libxcb
    libx11
    libxext
    libxrender
    libxrandr
    libXScrnSaver
    libxi
    xcbutil
    xcbutilwm
    xcbutilrenderutil
    xcbutilkeysyms
    xcbutilimage
    libxdmcp
    libxau
    llvmPackages.libcxx
    llvmPackages.libunwind
    # icu  #? is needed for dotnet based Bin/Ascon.HelpCall, but idk how to pass it
  ];
  installPhase = ''
    runHook preInstall

    mkdir --parents $out/{bin,opt,share}/
    cp --recursive etc opt $out/
    [ -d usr/bin ] && cp --recursive usr/bin $out/
    [ -d usr/share ] && cp --recursive usr/share $out/
    rm --recursive --force $out/share/fly-wm

    basepath=$out/opt/ascon/${appDir}

    if [ -e $basepath/Bin/kKompas ]; then
      ln --symbolic $basepath/Bin/kKompas $out/bin/kompas${v}
    fi
    if [ -e $basepath/Bin/kStudy ]; then
      ln --symbolic $basepath/Bin/kStudy $out/bin/kompas-study${v}
    fi
    if [ -e $basepath/Bin/kHome ]; then
      ln --symbolic $basepath/Bin/kHome $out/bin/kompas-home${v}
    fi
    if [ -e $basepath/Bin/kViewer ]; then
      ln --symbolic $basepath/Bin/kViewer $out/bin/kompas3d-viewer${v}
    fi
    if [ -e $basepath/License/kactivation ]; then
      ln --symbolic $basepath/License/kactivation $out/bin/kompas-kactivation${v}
    fi
    if [ -e $out/opt/ascon/polynom-library ]; then
      ln --symbolic $out/opt/ascon/polynom-library $basepath/Libs/PolynomLib
    fi
    if [ -e $out/opt/ascon/polynom-parts ]; then
      ln --symbolic $out/opt/ascon/polynom-parts $basepath/Libs/PolynomLib
    fi

    if [ -d $out/share/applications ]; then
      substituteInPlace $out/share/applications/*.desktop \
        --replace-quiet "/opt/ascon/kompas3d${v}" "$basepath" \
        --replace-quiet "/opt/ascon/kompas3d-viewer${v}" "$basepath"
      substituteInPlace $out/share/applications/*help*.desktop \
        --replace-fail "$basepath" "env DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 $basepath"
    fi

    examplesfile=$basepath/Bin/UIConfig/Examples.xml
    if [ -f "$examplesfile" ]; then
      iconv --from-code UTF-16LE --to-code UTF-8 $examplesfile --output $examplesfile
      substituteInPlace $examplesfile \
        --replace-fail "..\Samples" "$out\opt\ascon\${appDir}\Samples"
      iconv --from-code UTF-8 --to-code UTF-16LE $examplesfile --output $examplesfile
    fi

    find $out -xtype l -delete

    runHook postInstall
  '';
  preFixup = ''
    autoPatchelf -- $out/opt/ascon/${appDir}
  '';
  autoPatchelfIgnoreMissingDeps = [
    "*.tx"
    "*.txv"
    "*.rtw"
    "liboless.so"
    "libQt5Widgets.so.5"
    "libQt5Gui.so.5"
  ];
  dontAutoPatchelf = true;
  dontBuild = true;
  passthru = {
    inherit
      edition
      binary
      appDir
      version
      ;
  };
  meta = {
    inherit mainProgram;
    description = "КОМПАС-3D для машиностроения и приборостроения (${editionDescription})";
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
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ barsikus007 ];
    platforms = [ "x86_64-linux" ];
  };
}

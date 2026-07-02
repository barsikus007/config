{
  fetchurl,

  gobject-introspection,
  wrapGAppsHook3,

  python3,

  bcompare,
}:
let
  #? https://www.scootersoftware.com/download/v5changelog
  version = "5.2.3.32296";

  src = fetchurl {
    url = "https://www.scootersoftware.com/files/bcompare-${version}_amd64.deb";
    sha256 = "sha256-dkO5y4Q6Uu5xttnLIv+hbvwo4cVjmrNnXdD074TVAYQ=";
  };

  python = python3.withPackages (
    pp: with pp; [
      pygobject3
    ]
  );
in
(bcompare.overrideAttrs (previousAttrs: {
  inherit src version;

  nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
    gobject-introspection
    wrapGAppsHook3
  ];

  installPhase = (previousAttrs.installPhase or "") + /* bash */ ''
    substituteInPlace $out/lib/beyondcompare/bcmount.sh \
      --replace-fail "python3" "${python.interpreter}"

    #? prefer native wayland (fixes DnD via xwayland bridge), fall back to xcb on X sessions
    substituteInPlace $out/bin/bcompare \
      --replace-fail "QT_QPA_PLATFORM=xcb" 'QT_QPA_PLATFORM="wayland;xcb"'
  '';
}))

{
  pkgs,
  config,
  options,
  ...
}:
let
  inherit (pkgs) lib;
  blacklist = [
    "google-chrome-dev"
    "google-chrome-beta"
  ];
  hmConfig = builtins.head (lib.attrValues config.home-manager.users);
  hmOptions = options.home-manager.users.type.getSubOptions [ ];
  inherit (config.environment) systemPackages;
  homePackages = hmConfig.home.packages;

  getEnable =
    programsToCheck: n:
    let
      # TODO: match by package
      modEval = builtins.tryEval programsToCheck.${n};
    in
    if modEval.success then
      let
        enableEval = builtins.tryEval (modEval.value.enable or false);
      in
      if enableEval.success then enableEval.value else false
    else
      false;
  #? renamed options carry `apply = _: <target value>`, which aborts (not throws, so tryEval is
  #? useless) when the target no longer exists; they are only recognizable through their declaration
  isAliasOption =
    opt:
    let
      description = opt.description or null;
    in
    builtins.isString description && lib.strings.hasPrefix "Alias of " description;
  isObsolete =
    optionsToCheck: n:
    let
      opt = optionsToCheck.${n} or { };
    in
    isAliasOption opt
    || lib.lists.any (leaf: isAliasOption (opt.${leaf} or { })) [
      "enable"
      "package"
    ];
  checkStateEqualTo =
    enabledState: optionsToCheck: programsToCheck:
    builtins.filter (n: (getEnable programsToCheck n) == enabledState) (
      builtins.filter (n: !(isObsolete optionsToCheck n)) (
        lib.lists.subtractLists blacklist (builtins.attrNames programsToCheck)
      )
    );
  #? comparing derivations forces outPath -> the whole dependency closure, so a single
  #? broken dep (unsupported python interpreter etc) escapes tryEval; match by name instead
  safeName =
    pkg:
    let
      nameEval = builtins.tryEval (if lib.isDerivation pkg then lib.strings.getName pkg else null);
    in
    if nameEval.success then nameEval.value else null;
  packageNames = packages: lib.unique (builtins.filter (x: x != null) (map safeName packages));
  comparePackages =
    names: n:
    let
      modEval = builtins.tryEval (
        let
          name = safeName (n.package or null);
        in
        name != null && builtins.elem name names
      );
    in
    modEval.success && modEval.value;
  allExplicitPkgs =
    config.environment.systemPackages
    ++ lib.concatMap (u: u.home.packages) (lib.attrValues config.home-manager.users)
    ++ lib.concatMap (u: u.packages) (lib.attrValues config.users.users)
    ++ config.fonts.packages
    ++ [ config.boot.kernelPackages.kernel ];

  isUnfree =
    pkg:
    let
      licenses = lib.toList (pkg.meta.license or [ ]);
    in
    lib.any (l: !(l.free or true)) licenses;

  getIntrospection =
    config': options': packages':
    let
      names' = packageNames packages';
      checkPrograms = state: checkStateEqualTo state options'.programs config'.programs;
      checkServices = state: checkStateEqualTo state options'.services config'.services;
    in
    {
      enabledPrograms = lib.attrsets.getAttrs (checkPrograms true) config'.programs;
      enabledServices = lib.attrsets.getAttrs (checkServices true) config'.services;
      programsToEnable = lib.attrsets.filterAttrs (_: v: comparePackages names' v) (
        lib.attrsets.getAttrs (checkPrograms false) config'.programs
      );
      servicesToEnable = lib.attrsets.filterAttrs (_: v: comparePackages names' v) (
        lib.attrsets.getAttrs (checkServices false) config'.services
      );
    };
in
{
  nixos = getIntrospection config options systemPackages;
  home = getIntrospection hmConfig hmOptions homePackages;
  unfreeApps = map lib.strings.getName (lib.unique (lib.filter isUnfree allExplicitPkgs));
}

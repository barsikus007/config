#! NIXPKGS_ALLOW_BROKEN=1 NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild repl
{ pkgs, config, ... }:
let
  inherit (pkgs) lib;
  blacklist = [
    "frp"
    "redis"
    "vmalert"
    "sketchybar"
    "google-chrome-dev"
    "google-chrome-beta"
  ];
  hmConfig = builtins.head (lib.attrValues config.home-manager.users);
  inherit (config.environment) systemPackages;
  homePackages = hmConfig.home.packages;
in
let
  getEnable =
    programsToCheck: n:
    let
      # TODO: match by package
      modEval = builtins.tryEval (programsToCheck.${n});
    in
    if modEval.success then
      let
        enableEval = builtins.tryEval (modEval.value.enable or false);
      in
      if enableEval.success then enableEval.value else false
    else
      false;
  # TODO: filter obsolete
  checkStateEqualTo =
    enabledState: programsToCheck:
    builtins.filter (n: (getEnable programsToCheck n) == enabledState) (
      lib.lists.subtractLists blacklist (builtins.attrNames programsToCheck)
    );
  comparePackages =
    packages: n:
    let
      modEval = builtins.tryEval (n.package or null);
    in
    if modEval.success then builtins.elem modEval.value packages else false;
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

  getUntrospection = config': packages': {
    enabledPrograms = lib.attrsets.getAttrs (checkStateEqualTo true config'.programs) config'.programs;
    enabledServices = lib.attrsets.getAttrs (checkStateEqualTo true config'.services) config'.services;
    programsToEnable = lib.attrsets.filterAttrs (_: v: comparePackages packages' v) (
      lib.attrsets.getAttrs (checkStateEqualTo false config'.programs) config'.programs
    );
    servicesToEnable = lib.attrsets.filterAttrs (_: v: comparePackages packages' v) (
      lib.attrsets.getAttrs (checkStateEqualTo false config'.services) config'.services
    );
  };
in
{
  nixos = getUntrospection config systemPackages;
  home = getUntrospection hmConfig homePackages;
  unfreeApps = lib.unique (lib.filter isUnfree allExplicitPkgs);
}

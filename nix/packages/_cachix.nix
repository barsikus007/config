{
  lib,
  pkgs,
  self,
  system,
}:
let
  cfg = self.nixosConfigurations.ROG14.config;
  hm = cfg.home-manager.users.${lib.head (lib.attrNames cfg.home-manager.users)};
  nvidia = cfg.boot.kernelPackages.nvidiaPackages.stable;
in
{
  __cachix = {
    #? cachyos kernel modules are never in hydra cache
    xpadneo = cfg.boot.kernelPackages.xpadneo;
    xpad-noone = cfg.boot.kernelPackages.xpad-noone;
    kvmfr = cfg.boot.kernelPackages.kvmfr;
    v4l2loopback = cfg.boot.kernelPackages.v4l2loopback;
    intel-iwlwifi = lib.head (
      lib.filter (p: lib.hasPrefix "intel-iwlwifi" p.name) cfg.boot.extraModulePackages
    );
    nvidia-open = nvidia.open;
    nvidia-settings = nvidia.settings;

    #? the nixos module bakes zfs_cachyos (custom kernel) into the package
    podman = cfg.virtualisation.podman.package;

    #? nixcord never in hydra cache
    discord = hm.programs.nixcord.finalPackage.discord;
    vesktop = hm.programs.nixcord.finalPackage.vesktop;

    #? custom src rev, never in hydra cache
    looking-glass-client = hm.programs.looking-glass-client.package;
    keepassxc = self.packages.${system}.keepassxc;

    #? custom packages
    libspeedhack = self.packages.${system}.libspeedhack;
    libfprint-goodixtls = self.packages.${system}.libfprint-goodixtls-27c6-521d;
    hyprwhspr-rs = cfg.services.hyprwhspr-rs.package;
  };

  #? aggregate for the CI single-job build+push; its closure is the union of all targets
  #! every output of every drv must be linked: outputs of one drv are indivisible at substitution
  #! time, so a missing lib32/firmware would rebuild the whole nvidia-x11 drv locally
  __cachix-all = pkgs.linkFarm "cachix-all" (
    lib.concatMapAttrs (
      name: drv:
      lib.listToAttrs (
        map (output: {
          name = if output == "out" then name else "${name}-${output}";
          value = drv.${output};
        }) drv.outputs
      )
    ) self.legacyPackages.${system}.__cachix
  );
}

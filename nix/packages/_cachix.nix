{
  lib,
  pkgs,
  self,
  system,
}:
let
  cfg = self.nixosConfigurations.ROG14.config;
  nvidia = cfg.boot.kernelPackages.nvidiaPackages.stable;
in
{
  __cachix = {
    v4l2loopback = cfg.boot.kernelPackages.v4l2loopback;
    intel-iwlwifi = lib.head (
      lib.filter (p: lib.hasPrefix "intel-iwlwifi" p.name) cfg.boot.extraModulePackages
    );
    nvidia-open = nvidia.open;
    nvidia-x11 = nvidia;
    nvidia-settings = nvidia.settings;

    keepassxc = self.packages.${system}.keepassxc;
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

{
  lib,
  pkgs,
  config,
  username,
  extendModules ? null,
  ...
}:
let
  cfg = config.stylix-activationless;

  commonModule = {
    stylix-activationless.enable = lib.mkForce false;
  };

  lightSys = extendModules {
    modules = [
      commonModule
      {
        stylix = {
          base16Scheme = lib.mkForce cfg.light.base16Scheme;
          image = lib.mkForce cfg.light.image;
          polarity = lib.mkForce cfg.light.polarity;
        };
        home-manager.users.${username} = {
          programs.bat.config.theme = lib.mkForce "Coldark-Cold";
        };
      }
    ];
  };

  darkSys = extendModules {
    modules = [ commonModule ];
  };

  # user diff
  baseHome = darkSys.config.home-manager.users.${username}.home.file;
  lightHome = lightSys.config.home-manager.users.${username}.home.file;
  allHomeKeys = builtins.filter (k: baseHome ? ${k} && lightHome ? ${k}) (
    builtins.attrNames (baseHome // lightHome)
  );

  #? ignore paths dependent on any environment change
  isUserIgnored =
    target:
    lib.hasInfix "systemd/user" target
    || lib.hasInfix "mozilla/firefox" target
    || lib.hasInfix "zsh/" target
    || lib.hasInfix ".profile" target
    || lib.hasInfix "autostart" target
    || lib.hasInfix "environment.d" target;

  #? all themed paths
  themeHomeKeys = builtins.filter (
    k:
    let
      b = baseHome.${k};
      l = lightHome.${k};
      target = b.target or k;
    in
    !isUserIgnored target
    && (
      if (b ? text && l ? text && b.text != null && l.text != null) then
        b.text != l.text
      else
        (toString b.source) != (toString l.source)
    )
  ) allHomeKeys;
  getHomeSource =
    s: k:
    let
      entry = s.config.home-manager.users.${username}.home.file.${k};
    in
    if entry ? source && entry.source != null then
      entry.source
    else
      pkgs.writeText (baseNameOf (entry.target or k)) entry.text;
  userDarkFarm = pkgs.linkFarm "stylix-user-dark" (
    map (k: {
      name = baseHome.${k}.target or k;
      path = getHomeSource darkSys k;
    }) themeHomeKeys
  );
  userLightFarm = pkgs.linkFarm "stylix-user-light" (
    map (k: {
      name = baseHome.${k}.target or k;
      path = getHomeSource lightSys k;
    }) themeHomeKeys
  );
in
{
  options.stylix-activationless = {
    enable = lib.mkEnableOption "activationless Stylix theme switching" // {
      default = true;
    };
    lightConfig = lib.mkOption {
      internal = true;
      type = lib.types.anything;
      default = lightSys.config;
      description = "evaluated light configuration";
    };
    light = {
      polarity = lib.mkOption {
        type = lib.types.str;
        default = "light";
      };
      base16Scheme = lib.mkOption {
        type = lib.types.anything;
        default = "${pkgs.base16-schemes}/share/themes/github.yaml";
      };
      image = lib.mkOption {
        type = lib.types.anything;
        default = pkgs.fetchurl {
          url = "https://w.wallhaven.cc/full/zy/wallhaven-zy3r2w.png";
          hash = "sha256-O9INURruZK+bW3ZJmSD1lj50MviTOiuLCa9j7SUehvY=";
        };
      };
    };
    farms = {
      userDark = lib.mkOption {
        internal = true;
        type = lib.types.package;
        default = userDarkFarm;
      };
      userLight = lib.mkOption {
        internal = true;
        type = lib.types.package;
        default = userLightFarm;
      };
    };
    scripts = {
      darkPlasma = lib.mkOption {
        internal = true;
        type = lib.types.nullOr lib.types.path;
        default =
          let
            raw = darkSys.config.home-manager.users.${username}.home.activation.configure-plasma.data or "";
            words = lib.splitString " " (lib.trim raw);
          in
          if builtins.length words >= 2 then builtins.elemAt words 1 else null;
      };
      lightPlasma = lib.mkOption {
        internal = true;
        type = lib.types.nullOr lib.types.path;
        default =
          let
            raw = lightSys.config.home-manager.users.${username}.home.activation.configure-plasma.data or "";
            words = lib.splitString " " (lib.trim raw);
          in
          if builtins.length words >= 2 then builtins.elemAt words 1 else null;
      };
    };
  };

  config = lib.mkIf (config.stylix.enable && cfg.enable && extendModules != null) {
    home-manager.users.${username} = {
      imports = [
        ../home/stylix-darkman.nix
        { programs.bat.config.theme = "Coldark-Dark"; }
      ];

      home.file = lib.genAttrs themeHomeKeys (k: {
        source = lib.mkForce (
          config.home-manager.users.${username}.lib.file.mkOutOfStoreSymlink
            "/home/${username}/.local/state/stylix/current/${baseHome.${k}.target or k}"
        );
      });
    };
  };
}

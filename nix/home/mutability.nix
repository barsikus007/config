{ lib, config, ... }:
#? enables mutable = true on home.file and xdg.*File
#? based on https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
let
  fileOptionAttrPaths = [
    [
      "home"
      "file"
    ]
    [
      "xdg"
      "configFile"
    ]
    [
      "xdg"
      "dataFile"
    ]
    [
      "xdg"
      "stateFile"
    ]
    [
      "xdg"
      "cacheFile"
    ]
  ];

  fileAttrsType = lib.types.attrsOf (
    lib.types.submodule (
      { config, ... }:
      {
        options.mutable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to copy the file without the read-only attribute instead of
            symlinking. If set to `true`, `force` is automatically enabled.
          '';
        };

        config = lib.mkIf config.mutable {
          force = true;
        };
      }
    )
  );
in
{
  options = builtins.foldl' lib.recursiveUpdate { } (
    map (
      attrPath: lib.setAttrByPath attrPath (lib.mkOption { type = fileAttrsType; })
    ) fileOptionAttrPaths
  );

  config =
    let
      #? home.file already collects entries from xdg.configFile, xdg.dataFile, xdg.stateFile, xdg.cacheFile
      allFiles = builtins.attrValues (config.home.file or { });

      mutableFiles = builtins.filter (file: (file.enable or true) && (file.mutable or false)) allFiles;

      toCommand =
        file:
        let
          source = lib.escapeShellArg file.source;
          target = lib.escapeShellArg "${config.home.homeDirectory}/${file.target}";
        in
        ''
          $VERBOSE_ECHO "${source} -> ${target}"
          $DRY_RUN_CMD cp --remove-destination --no-preserve=mode ${source} ${target}
        '';
    in
    {
      home.activation.mutableFileGeneration = lib.mkIf (mutableFiles != [ ]) (
        lib.hm.dag.entryAfter [ "linkGeneration" ] (
          ''
            echo "Copying mutable home files for $HOME"
          ''
          + lib.concatLines (map toCommand mutableFiles)
        )
      );
    };
}

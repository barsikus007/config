{ pkgs, username, ... }:
{
  programs.adb.enable = true;
  users.users.${username}.extraGroups = [ "adbusers" ];

  environment.defaultPackages = with pkgs; [
    android-file-transfer
    # adbfs-rootless
    #? https://github.com/spion/adbfs-rootless/pull/73
    # (adbfs-rootless.overrideAttrs (old: {
    #   patches = (old.patches or [ ]) ++ [
    #     (fetchpatch {
    #       url = "github.com/spion/adbfs-rootless/pull/73.patch";
    #       hash = "sha256-S3KY3xy+939nkYyJerC+rKemcqocbxPV7bwjZKMkeJQ=";
    #     })
    #   ];
    # }))
    #? https://github.com/spion/adbfs-rootless/issues/56
    (adbfs-rootless.overrideAttrs (old: {
      pname = old.pname + "-libfuse-3";

      src = fetchFromGitHub {
        owner = "spion";
        repo = "adbfs-rootless";
        # rev = "feat/merge-libfuse-3";
        rev = "cf2f8ae0feeb41e4abaf59e166d1337cc87204c8";
        sha256 = "sha256-FWGJyJv7c0FZ6NvepcavxWpeUT0KanU8D4B1FL7QxPI=";
      };

      buildInputs = [ fuse3 ];
    }))
  ];
}

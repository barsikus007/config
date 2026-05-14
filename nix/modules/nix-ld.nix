{ pkgs, ... }:
#? https://wiki.nixos.org/wiki/Nix-ld
#? https://unix.stackexchange.com/a/522823
{
  programs.nix-ld.libraries =
    with pkgs;
    builtins.concatLists [
      #? nix-locate lib/libgobject-2.0.so.0
      [
        nss
        nspr
        cups
        # fuse3
        # icu
        expat
        # vulkan-headers
        # vulkan-tools

        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxkbcommon
        libxrandr

        at-spi2-atk
        alsa-lib
        cairo
        dbus
        freetype
        gdk-pixbuf
        glib
        gtk3
        pango
      ]
      (steam-run.args.multiPkgs pkgs)
    ];
}

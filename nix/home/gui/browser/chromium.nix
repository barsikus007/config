{
  custom.persist.home.directories = [ ".config/BraveSoftware" ];

  #! vivaldi is unfree :(
  programs.brave = {
    enable = true;
    extensions = [
      # https://chromewebstore.google.com/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm
      "cjpalhdlnbpafiamejdnhcphjbkeiagm"
      # https://chromewebstore.google.com/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag
      "jinjaccalgkegednnccohejagnlnfdag"
      # https://chromewebstore.google.com/detail/keepassxc-browser/oboonakemofpalcgghocfoadofidjkkk
      "oboonakemofpalcgghocfoadofidjkkk"
    ];
  };
}

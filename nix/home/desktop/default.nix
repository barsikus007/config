{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../gui/terminal.nix
    ./environment/launcher.nix
  ];
  home.packages = (import ../../shared/shell-scripts.nix { inherit pkgs; });
  services.cliphist.enable = true;
  #! vibecoded shitfix for fprint pam
  #! HM-модуль делает текстовый watcher как `wl-paste --watch` без --type -> он читает и картинки тоже
  #! ayugram-картинки виснут на чтении -> watcher залипает навсегда и перестаёт писать текст в историю (Restart=on-failure не ловит: висит, а не падает)
  #? добавляем --type text (как рекомендует апстрим cliphist), картинки читает только cliphist-images
  systemd.user.services.cliphist.Service.ExecStart = lib.mkForce (
    "${lib.getExe' config.services.cliphist.clipboardPackage "wl-paste"} --type text --watch "
    + "${lib.getExe config.services.cliphist.package} "
    + "${lib.escapeShellArgs config.services.cliphist.extraOptions} store"
  );
  #! wayland: selection живёт пока жив владелец -> при закрытии источника буфер пропадает (проверено: закрыл все wezterm -> пусто)
  #? persist держит копию и перезахватывает selection
  #! --selection-size-limit НЕ спасает от подвисания: чтобы измерить размер, persist сперва читает все mime (вкл. огромный BMP) -> источник виснет
  #? --all-mime-type-regex фильтрует по списку mime из offer (дешёвые строки, ДО чтения) -> выделения с image/ пропускаем, не читая
  #? картинки не персистятся (историю держит cliphist-images, читая только сжатый PNG), зато нет подвисания
  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "Keep Wayland clipboard after source program exits";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      #! negative lookahead: обрабатываем выделение только если НИ один offered mime не начинается с image/
      ExecStart = "${lib.getExe' pkgs.wl-clip-persist "wl-clip-persist"} --clipboard regular --all-mime-type-regex '^(?!image/).+'";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}

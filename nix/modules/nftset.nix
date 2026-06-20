{ lib, ... }:
let
  mkLine =
    {
      set,
      domains,
      family ? "4",
      table ? "split-routing",
      comment ? "",
    }:
    "nftset=/${lib.concatStringsSep "/" domains}/${family}#inet#${table}#${set} # ${comment}";
  globalSet = "force_exit";
  ruSet = "force_direct";
in
map mkLine [
  {
    comment = "youtube";
    set = globalSet;
    domains = [
      "youtube.com"
      "googlevideo.com"
    ];
  }
  #? https://github.com/Flowseal/zapret-discord-youtube/issues/5820#issuecomment-4070212332
  {
    comment = "telegram";
    set = globalSet;
    domains = [
      # "91.108.56.0/22"
      # "91.108.4.0/22"
      # "91.108.8.0/22"
      # "91.108.16.0/22"
      # "91.108.12.0/22"
      # "149.154.160.0/20"
      # "91.105.192.0/23"
      # "91.108.20.0/22"
      # "185.76.151.0/24"
      "cdn-telegram.org"
      "comments.app"
      "contest.com"
      "fragment.com"
      "graph.org"
      "quiz.directory"
      "t.me"
      "tdesktop.com"
      "telega.one"
      "telegra.ph"
      "telegram-cdn.org"
      "telegram.dog"
      "telegram.me"
      "telegram.org"
      "telegram.space"
      "telesco.pe"
      "tg.dev"
      "ton.org"
      "tx.me"
      "usercontent.dev"
    ];
  }
  {
    # comment = "telegram";
    # family = "6";
    # set = globalSet;
    # domains = [
    #   "2001:b28:f23d::/48"
    #   "2001:b28:f23f::/48"
    #   "2001:67c:4e8::/48"
    #   "2001:b28:f23c::/48"
    #   "2a0a:f280::/32"
    # ];
  }

  {
    comment = "ru";
    set = ruSet;
    domains = [
      "ru"
      "xn--p1ai"
      "2gis.com"
      "avito.st"
      "sberbank.com"
      "alfabank.st"
    ];
  }
  {
    comment = "ru vk";
    set = ruSet;
    domains = [
      "vk.com"
      "userapi.com"
      "vk-cdn.net"
      "vkuser.net"
      "mycdn.me"
    ];
  }
  {
    comment = "ru ya";
    set = ruSet;
    domains = [
      "yandex.net"
      "yastat.net"
      "yastatic.net"
      "yandex.cloud"
      "yandexcloud.net"
    ];
  }
]

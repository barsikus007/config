#? single source of truth for split-routing domain lists, shared by two consumers:
#?   - modules/nftset.nix        -> dnsmasq nftset lines for pihole on the VPS
#?   - packages/openwrt/dewclaw  -> pbr policies on the router
#? via = "exit"   -> nftset force_exit,   pbr interface awg0
#? via = "direct" -> nftset force_direct, pbr interface wan
#? cidrs are pbr-only: dnsmasq nftset matches domains, not networks
#? dns/router flags exist to drop a group from one consumer without splitting the list
{
  groups = [
    {
      domains = [
        "rutor.info"
        "rutor.is"
        "rutracker.org"
        "nnmclub.to"
        "nyaa.si"
        "themoviedb.org"
        "cub.red"
      ];
      name = "torrents";
      via = "exit";
    }
    {
      domains = [
        "shikimori.me"
        "jut.su"
        "animego.org"
        "amedia.site"
        "yummyanime.tv"
        "nhentai.net"
      ];
      name = "anime-nonru";
      via = "exit";
    }
    {
      domains = [
        "memepedia.ru"
        "api.github.com"
        "githubcopilot.com"
        "instagram.com"
        "nhentai.net"
        "relays.syncthing.net"
        "crowdsec.net"
        "cachix.org"
      ];
      name = "non-ru";
      via = "exit";
    }
    {
      domains = [
        "chatgpt.com"
        "anthropic.com"
        "claude.ai"
        "groq.com"
      ];
      name = "ai";
      via = "exit";
    }
    {
      domains = [
        #? bare gTLD, google actually operates it
        "youtube"
        "ggpht.com"
        "googlevideo.com"
        "wide-youtube.l.google.com"
        "withyoutube.com"
        "youtu.be"
        "youtube-nocookie.com"
        "youtube-ui.l.google.com"
        "youtube.com"
        "youtube.googleapis.com"
        "youtubeeducation.com"
        "youtubeembeddedplayer.googleapis.com"
        "youtubefanfest.com"
        "youtubegaming.com"
        "youtubego.co.id"
        "youtubego.co.in"
        "youtubego.com"
        "youtubego.id"
        "youtubego.in"
        "youtubei.googleapis.com"
        "youtubekids.com"
        "youtubemobilesupport.com"
        "yt.be"
        "ytimg.com"
        "yt3.googleusercontent.com"
        #? not youtube, but they rode along in the same pbr policy
        "www.instagram.com"
        "www.tiktok.com"
      ];
      name = "youtube";
      via = "exit";
    }
    #? https://github.com/Flowseal/zapret-discord-youtube/issues/5820#issuecomment-4070212332
    {
      cidrs = [
        "91.108.56.0/22"
        "91.108.4.0/22"
        "91.108.8.0/22"
        "91.108.16.0/22"
        "91.108.12.0/22"
        "149.154.160.0/20"
        "91.105.192.0/23"
        "91.108.20.0/22"
        "185.76.151.0/24"
      ];
      domains = [
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
      name = "telegram";
      via = "exit";
    }
    {
      cidrs = [
        "2001:b28:f23d::/48"
        "2001:b28:f23f::/48"
        "2001:67c:4e8::/48"
        "2001:b28:f23c::/48"
        "2a0a:f280::/32"
      ];
      enabled = false;
      family = "6";
      name = "telegram-v6";
      via = "exit";
    }
    {
      domains = [
        "dis.gd"
        "discord.co"
        "discord.com"
        "discord.design"
        "discord.dev"
        "discord.gg"
        "discord.gift"
        "discord.gifts"
        "discord.media"
        "discord.new"
        "discord.store"
        "discordapp.com"
        "discordapp.net"
        "discordmerch.com"
        "discordactivities.com"
        "discordsays.com"
        "discordstatus.com"
      ];
      name = "discord";
      via = "exit";
    }

    {
      domains = [
        "animego.me"
        "aniboom.one"
        "kodik.info"
        "senkuro.me"
        "mangalib.me"
        "cdnlibs.org"
      ];
      enabled = false;
      name = "anime-ru";
      via = "direct";
    }
    {
      domains = [
        "ru"
        "xn--p1ai"
        "2gis.com"
        "avito.st"
        "sberbank.com"
        "alfabank.st"
        "hcaptcha.com"
        "ngenix.net"
        "tpass.me"
        "boosty.to"
        "cdnvideohub.com"
        "otzovik.com"
        "x5static.net"
      ];
      name = "ru";
      via = "direct";
    }
    {
      domains = [
        "vk.com"
        "userapi.com"
        "vk-cdn.net"
        "vkuser.net"
        "mycdn.me"
      ];
      name = "ru-vk";
      via = "direct";
    }
    {
      domains = [
        "yandex.net"
        "yastat.net"
        "yastatic.net"
        "yandex.cloud"
        "yandexcloud.net"
      ];
      name = "ru-ya";
      via = "direct";
    }
    {
      domains = [
        "reddit.com"
        "m5stack.com"
        "aliyuncs.com"
        "imgur.com"
        "gommehd.net"
      ];
      name = "shit-sites";
      via = "direct";
    }
  ];
}

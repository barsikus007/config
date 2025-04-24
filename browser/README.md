# [Browser](../README.md)

## Userscripts

- <https://greasyfork.org/en/scripts/439993-youtube-shorts-redirect>
- [TODO remove si youtube](https://github.com/Xenorio/YTShareAntiTrack)
- [VK](http://greasyfork.org/scripts/518509)
- [own](./userscripts)
- TODO
  - ExchangeRater.user imperial units converter
  - yt watch later icon on video card
  - open in webarchive (RCM)

## Favorites

- WebArchive
  - `javascript:window.open(location.href.replace(/^(https?:\/\/)/i, "https://web.archive.org/web/0/$1"), "_blank")`
- Reddit undelete
  - `javascript:window.open(location.href.replace(/:\/\/([\w-]+.)?(reddit\.com\/r|reveddit\.com\/v)\//i, "://undelete.pullpush.io/r/"), "_blank")`
- Shikimori to `yummy-anime.ru`
  - `javascript:window.open(location.href.replace(/https:\/\/shikimori\.one\/animes\/\w?\d*-/i, "https://yummy-anime.ru/search?word="), "_blank")`
- NixOS wiki
  - `javascript:window.open(location.href.replace(/https:\/\/nixos\.wiki\//i, "https://wiki.nixos.org/"), "_blank")`
  - or better `https://gist.githubusercontent.com/pokedim13/469a4fc6a3c5b419fe337886e1e3be10/raw/nixos-wiki.js`

## uBlock

### Enable `AdGuard,ru` filters

<extension://odfafepnkmbhccpbejgmiehpchacaeak/dashboard.html#3p-filters.html>

### My filters

<extension://odfafepnkmbhccpbejgmiehpchacaeak/dashboard.html#1p-filters.html>

```css
! 2022-02-22 https://lurkmore.media
lurkmore.media##.sitenotice
```

[VK](https://github.com/vtosters/adblock)

## Flags

- Flag for faster downloads
  - <edge://flags/#enable-parallel-downloading> -> `Enabled`
- Flag for QUIC protocol
  - <edge://flags/#enable-quic> -> `Enabled`
- [Fix for workspaces sidebar](https://answers.microsoft.com/en-us/microsoftedge/forum/all/how-to-remove-the-edge-sidebar-from-edge-workspace/bde1ede5-12a3-4f99-ac16-50b0f9878054?page=5)
  - <edge://flags/#edge-workspaces-skype-entry-point> -> `Enabled Hub chat icon`

## Extensions

- ShitBlockers
  - [uBlock Origin](https://ublockorigin.com)
    - [AdNauseam](https://adnauseam.io)
  - [I don't care about cookies](https://www.i-dont-care-about-cookies.eu)
  - [ClearURLs](https://docs.clearurls.xyz/)
- Scripts
  - [Violentmonkey](https://violentmonkey.github.io/)
- YouTube
  - [Return YouTube Dislike](https://www.returnyoutubedislike.com/)
  - [SponsorBlock for YouTube - Skip Sponsorships](https://sponsor.ajay.app)
- [QuicKey](https://fwextensions.github.io/QuicKey/)
  - [C+Tab](https://fwextensions.github.io/QuicKey/ctrl-tab/)
    - <edge://extensions/shortcuts>
      - `chrome.developerPrivate.updateExtensionCommand({extensionId: "mcjciddpjefdpndgllejgcekmajmehnd", commandName: "30-toggle-recent-tabs", keybinding: "Ctrl+Tab"});`
- [PiP - Picture in Picture Plus](https://www.oinkandstuff.com/project/pip-picture-in-picture-plus/)
- [Search by Image](https://github.com/dessant/search-by-image)
- [Refined GitHub](https://github.com/refined-github/refined-github)
- [Ruffle](https://ruffle.rs/)
- [Dark Reader](https://darkreader.org/)
- TODO
  - <https://extensions.xenorio.xyz/list/tubetweaks>
  - <https://github.com/dessant/ping-blocker>
  - <https://github.com/BrowserBoost/Extension>
  - <https://github.com/vknext/vk-classic-feed>
  - <https://github.com/zero-peak/ZeroOmega>
  - <https://selectorgadget.com/>
    - <https://github.com/hermit-crab/ScrapeMate>

## Dev Tools console

```js
// YouTube get all links from playlist to compare then with python
// [f"https://youtu.be/{id}" for id in (set(p1) - set(p2))]
[...document.querySelectorAll('ytd-item-section-renderer:not([is-playlist-video-container]) ytd-thumbnail > a')].map(el => el.href.slice(32,43))

// player playback speed
document.querySelector('video').playbackRate = 1.0;

// check if dark theme reported by browser
console.log(window.matchMedia("(prefers-color-scheme: dark)").matches)
```

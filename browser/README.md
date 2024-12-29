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

## uBlock

### My filters

<extension://odfafepnkmbhccpbejgmiehpchacaeak/dashboard.html#1p-filters.html>

```css
! 2023-12-31 https://mail.yandex.ru
mail.yandex.ru##div.ns-view-left-box > div:nth-of-type(2)
mail.yandex.ru##div[class^="DisableAdsButton__root"]
mail.yandex.ru##main.mail-Layout-Content > div:nth-of-type(2)

! 2024-01-02 https://www.youtube.com
||youtube.com^$removeparam=si

! 2024-07-18 https://medium.com
medium.com##div:has(> div:has(> div:has(> div:has(> div:has(> button[data-testid="close-button"])))))

! 2024-12-01 https://lurkmore.media
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
- [PiP - Picture in Picture Plus](https://www.oinkandstuff.com/project/pip-picture-in-picture-plus/)
- [Search by Image](https://github.com/dessant/search-by-image)
- [Refined GitHub](https://github.com/refined-github/refined-github)
- [Ruffle](https://ruffle.rs/)
- [Dark Reader](https://darkreader.org/)
- TODO
  - <https://extensions.xenorio.xyz/list/tubetweaks>
  - <https://github.com/dessant/ping-blocker>
  - <https://github.com/BrowserBoost/Extension>

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

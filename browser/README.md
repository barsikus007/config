# [Browser](../README.md)

## Tampermonkey scripts

- <https://greasyfork.org/en/scripts/439993-youtube-shorts-redirect>
- [TODO remove si youtube](https://github.com/Xenorio/YTShareAntiTrack)

## Extensions

- ShitBlockers
  - [uBlock Origin](https://ublockorigin.com)
    - [AdNauseam](https://adnauseam.io)
  - [I don't care about cookies](https://www.i-dont-care-about-cookies.eu)
  - [ClearURLs](https://docs.clearurls.xyz/)
- Scripts
  - [Tampermonkey](https://www.tampermonkey.net)
  - [Tampermonkey Editors](https://chrome.google.com/webstore/detail/tampermonkey-editors/lieodnapokbjkkdkhdljlllmgkmdokcm)
- YouTube
  - [Return YouTube Dislike](https://www.oinkandstuff.com/project/pip-picture-in-picture-plus/)
  - [SponsorBlock for YouTube - Skip Sponsorships](https://sponsor.ajay.app)
- [PiP - Picture in Picture Plus](https://www.oinkandstuff.com/project/pip-picture-in-picture-plus/)
- [Search by Image](https://github.com/dessant/search-by-image)
- TODO

## Dev Tools console

```js
// YouTube get all links from playlist to compare then with python
// [f"https://youtu.be/{id}" for id in (set(p1) - set(p2))]
[...document.querySelectorAll('ytd-item-section-renderer:not([is-playlist-video-container]) ytd-thumbnail > a')].map(el => el.href.slice(32,43))

// player playback speed
document.querySelector('video').playbackRate = 1.0;
```

# [YouTube ReVanced](./README.md)

## Correct update sequence

1. Unpatch app
   1. Better to reboot
2. Install new version
3. Patch and mount

## [YouTube](https://revanced.app/patches?pkg=com.google.android.youtube)

### [APKMirror](https://www.apkmirror.com/apk/google-inc/youtube/youtube-19.04.37-release/#downloads:~:text=Android%208.0%2B-,nodpi,-All%20Releases)

### Patches 21/62

- 4.3.0
  - Alternative thumbnails
  - Always repeat
  - Bypass URL redirects
  - Client spoof
  - Copy video URL
  - Disable player popup panels
  - Disable resuming Shorts on startup
  - External downloads
  - Hide ads
  - Minimized playback
  - Open links externally
  - Remove tracking query parameter
  - Remove viewer discretion dialog
  - Restore old video quality menu
  - Return Youtube Dislike
  - SponsorBlock
  - Swipe controls
  - Video ads
  - Hide get premium (removed)
  - Hide email address (removed)
  - Hide watermark (removed)
  - Premium heading (removed)
  - ?
    - Enable slide to seek
    - Restore old seekbar thumbnails
    - Seekbar tapping
  - ? not enabled
    - Hide breaking news shell

### Settings

- General
  - Double-tap to seek
    - 5 seconds
- Video quality preferences
  - \*
    - Higher picture quality
- ReVanced

```json
"disable_resuming_shorts_player": true,
"external_downloader": true,
"external_downloader_name": "com.junkfood.seal",
"hide_player_popup_panels": true,
"ryd_toast_on_connection_error": false,
"sb_local_time_saved_milliseconds": 667499,
"sb_local_time_saved_number_segments": 23,
"sb_toast_on_connection_error": false
```

## [YouTube Music](https://revanced.app/patches?pkg=com.google.android.apps.youtube.music)

### [APKMirror](https://www.apkmirror.com/apk/google-inc/youtube-music/)

### Patches 8/12

- 4.3.0
  - !GmsCore support (due to root)
  - !Compact header
  - !Permanent repeat
  - !Permanent shuffle

## Updated 2024-03-07

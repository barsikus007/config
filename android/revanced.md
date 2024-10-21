# [YouTube ReVanced](./README.md)

## Correct update sequence

1. Unpatch app
2. Install new version
3. Patch and mount

## [YouTube](https://revanced.app/patches?pkg=com.google.android.youtube)

### [APKMirror](https://www.apkmirror.com/apk/google-inc/youtube/youtube-19.17.42-release/#downloads:~:text=Android%208.0%2B-,nodpi,-All%20Releases)

### Patches 25/63

- 4.17.0
  - Alternative thumbnails
  - Always repeat
  - Bypass URL redirects
  - Bypass image region restrictions
  - Check watch history domain name resolution
  - Copy video URL
  - Disable player popup panels
  - Disable resuming Shorts on startup
  - Downloads
  - Hide ads
  - Open links externally
  - Remove background playback restrictions
  - Remove tracking query parameter
  - Remove viewer discretion dialog
  - Restore old video quality menu
  - Return Youtube Dislike
  - SponsorBlock
  - Spoof video streams
  - Swipe controls
  - Video ads
  - ! new
    - Miniplayer
  - ? test
    - Seekbar tapping
  - X broken
    - Enable slide to seek
    - Restore old seekbar thumbnails

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
"external_downloader_name": "com.deniscerri.ytdl",
"hide_player_popup_panels": true,
"ryd_toast_on_connection_error": false,
"sb_local_time_saved_milliseconds": 1737581,
"sb_local_time_saved_number_segments": 47,
"sb_toast_on_connection_error": false
```

## [YouTube Music](https://revanced.app/patches?pkg=com.google.android.apps.youtube.music)

### [APKMirror](https://www.apkmirror.com/apk/google-inc/youtube-music/)

### Patches 6/10

- 4.17.0
  - !GmsCore support (due to root)
  - !Hide category bar
  - !Permanent repeat
  - !Permanent shuffle

## Updated 2024-10-21

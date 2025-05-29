# [YouTube ReVanced](./README.md)

## Correct update sequence

1. Unmount app
2. Install new version
3. Patch and mount

## Correct fix sequence

If phone crashes, it causes base.apk of default apps reset their version

1. Install same version
2. Reboot/relaunch mount scripts

## [YouTube](https://revanced.app/patches?pkg=com.google.android.youtube)

- 5.24.0
  - Theme
    - Material You
  - !GmsCore support (due to root)

### Settings

- General
  - Double-tap to seek
    - 5 seconds
- Video quality preferences
  - \*
    - Higher picture quality
- ReVanced
  - Misc
    - Import / Export

```json
"disable_precise_seeking_gesture": true,
"disable_resuming_shorts_player": true,
"external_downloader": true,
"external_downloader_name": "com.deniscerri.ytdl",
"hide_player_popup_panels": true,
"miniplayer_type": "minimal",
"ryd_toast_on_connection_error": false,
"seekbar_tapping": true,
"shorts_player_type": "regular_player",
"spoof_app_version_target": "19.26.42",
"swipe_brightness": true,
"swipe_lowest_value_enable_auto_brightness": true,
"swipe_text_overlay_size": 22,
"swipe_volume": true,
"sb_local_time_saved_milliseconds": 3218098,
"sb_local_time_saved_number_segments": 80,
"sb_toast_on_connection_error": false
```

## [YouTube Music](https://revanced.app/patches?pkg=com.google.android.apps.youtube.music)

- 5.24.0
  - !Bypass certificate check (due to root)
  - !GmsCore support (due to root)
  - !Spoof client (due to root)

## Updated 2025-05-27

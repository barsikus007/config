# [YouTube ReVanced](./README.md)

## Correct update sequence

1. Unpatch app
2. Install new version
3. Patch and mount

## Correct fix sequence

If phone crashes, it causes base.apk of default apps reset their version

1. Install same version
2. Reboot/relaunch mount scripts

## [YouTube](https://revanced.app/patches?pkg=com.google.android.youtube)

### Patches 56/57 of Default

- 5.18.0
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
"announcement_last_id": 10,
"disable_resuming_shorts_player": true,
"external_downloader": true,
"external_downloader_name": "com.deniscerri.ytdl",
"hide_player_popup_panels": true,
"miniplayer_type": "minimal",
"swipe_lowest_value_enable_auto_brightness": true,
"ryd_toast_on_connection_error": false,
"sb_local_time_saved_milliseconds": 2643560,
"sb_local_time_saved_number_segments": 66,
"sb_toast_on_connection_error": false
```

## [YouTube Music](https://revanced.app/patches?pkg=com.google.android.apps.youtube.music)

### Patches 5/8 of Default

- 5.18.0
  - !Bypass certificate check (due to root)
  - !GmsCore support (due to root)
  - !Spoof client (due to root)

## Updated 2025-04-09

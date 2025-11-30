# [YouTube ReVanced](./README.md)

## correct update sequence

1. unmount app
2. install new version
3. patch and mount

## correct fix sequence

if phone crashes, it causes base.apk of default apps reset their version

1. install same version
2. reboot/relaunch mount scripts

## [YouTube](https://revanced.app/patches?pkg=com.google.android.youtube)

- 5.46.0
  - Theme
    - Material You
  - !GmsCore support (due to root)

### settings

- General
  - Double-tap to seek
    - 5 seconds
- Video quality preferences
  - \*
    - Higher picture quality
- ReVanced
  - Miscellaneous
    - Import / Export

```json
"custom_speed_menu": false,
"disable_precise_seeking_gesture": true,
"disable_resuming_shorts_player": true,
"external_downloader": true,
"force_original_audio": true,
"hide_player_popup_panels": true,
"miniplayer_type": "minimal",
"ryd_toast_on_connection_error": false,
"seekbar_tapping": true,
"shorts_player_type": "regular_player",
"swipe_brightness": true,
"swipe_lowest_value_enable_auto_brightness": true,
"swipe_volume": true,
"sb_local_time_saved_milliseconds": 4330921,
"sb_local_time_saved_number_segments": 120,
"sb_toast_on_connection_error": false
```

## [YouTube Music](https://revanced.app/patches?pkg=com.google.android.apps.youtube.music)

- 5.46.0
  - Theme
    - Material You
  - !Bypass certificate check (due to root)
  - !GmsCore support (due to root)

### settings

- ReVanced
  - Miscellaneous
    - Import / Export

```json
"music_hide_navigation_bar_explore_button": true,
"music_hide_navigation_bar_samples_button": true
```

## updated 2025-11-29

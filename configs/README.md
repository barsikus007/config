# [Configs](../README.md)

## [vscode](.config/vscode/)

- REMOVED from `settings.json`
  - remote.SSH.remotePlatform
  - sourcery.token
- TODO
  - extensions
  - windows layout

## [mpv](.config/mpv/)

- mpv.conf
  - no-border
  - snap-window
  - save-position-on-quit
  - screenshot-directory is desktop
  - ontop only when playing
  - profiles
    - playlist
      - move window to right down corner
      - resize to 25% of screen width
    - online (http)
      - same as playlist
    - music (mp3)
      - always show window
      - don't save position
  - TODO
    - headers based on link profile
    - additional track settings
      - sub/aud folder search
      - #Audio language priority
      - alang=ru,rus,en,eng,ja,jp,jpn
      - #Subtitle language priority
      - slang=ru,rus,en,eng,ja,jp,jpn
- input.conf
  - patched ru keybinds
  - middle mouse button to pin window on top
  - _/- to cycle video tracks
  - =/+ to cycle window sizes
  - Alt+[0-6] keys to change window size
  - k shuffle playlist
  - Alt+k unshuffle playlist
  - K loop/unloop playlist
  - n show file tags
  - [crop/encode](https://github.com/occivink/mpv-scripts/blob/master/input.conf)
    - crop
      - c for crop
      - Alt+c for soft crop
      - C for toggle crop (remove filter and crop)
      - l blur logo
      - d remove crop filter
      - D remove soft crop
    - encode
      - e for webm no audio
      - E for source
      - Alt+e for mp4 no audio
- [crop/encode scripts](https://github.com/occivink/mpv-scripts)
  - [crop fix](https://github.com/occivink/mpv-scripts/pull/77/files)

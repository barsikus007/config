# [cheatsheet for desktop](./README.md)

## plasma

- `kioclient exec <file>.desktop`

## waydroid

- <https://wiki.nixos.org/wiki/Waydroid#Installation>
  - `sudo waydroid init`
    - you can download OTA images located in `/var/lib/waydroid/waydroid.cfg` manually
    - extract them to `/var/lib/waydroid/images/`
    - and edit `waydroid.cfg` accordingly (set datetime variables)
- <https://wiki.nixos.org/wiki/Waydroid#Mount_host_directories>
  - after system startup `systemctl --user start waydroid-monitor`
  - mount dirs
    - `sudo waydroid shell mkdir /data/adb/modules/<module_id>`
    - `/run/media/admin/Data/projects/<module_id>` host
    - `/home/admin/.local/share/waydroid/data/adb/modules/<module_id>` waydroid
- props
  - `waydroid prop set persist.waydroid.multi_windows true`
    - funny, uses android windowed mode
  - `waydroid prop set persist.waydroid.width 480`
  - `waydroid prop set persist.waydroid.height 800`

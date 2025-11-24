# [Android](../README.md)

## devices

### [Oculus Quest 2](./devices/oculus.md)

### [Mi TV Stick](./devices/mitv.md)

### [Pixel 7 Pro](https://4pda.to/forum/index.php?showtopic=1039682)

- [root and kernel english](https://xdaforums.com/t/november-12-2023-up1a-231105-003-a1-for-jp-carriers-unlock-bootloader-root-pixel-7-pro-cheetah-safetynet.4502805/)
- [OTA](https://apatch.dev/update.html#ota-update-with-apatch-retention)
  - [Pixel Flasher](https://github.com/badabing2005/PixelFlasher/releases)
  - [root update russian](https://4pda.to/forum/index.php?s=&showtopic=1063306&view=findpost&p=120901180)
- [App Manager interceptor](https://www.reddit.com/r/fossdroid/comments/1g0lsit/app_manager_issue_it_automatically_options)

#### DEPRECATED

- Audio. Because no configuration and no difference.
  - [ViPERFX RE](https://github.com/AndroidAudioMods/ViPERFX_RE)
  - [ViPER4Android Repackaged](https://github.com/programminghoch10/ViPER4AndroidRepackaged)
  - [?Dolby Atmos](https://gitlab.com/reiryuki-the-fixer/dolby-atmos-magic-revision-magisk-module)
  - [no root - wavelet](https://4pda.to/forum/index.php?showtopic=1039682&view=findpost&p=119899326)

#### TODO

- root detectors
  - [momo](https://t.me/s/magiskalpha/529)
- Design and Tweak Mods
  - <https://github.com/Mahmud0808/Iconify>

## instructions

### [YouTube ReVanced](./revanced.md)

### [Termux](./termux.md)

### [root](./root.md)

### [install certificates](./certs.md)

### backup apps list

`adb shell` script:

```sh
folder="/sdcard/Download/APKs/app_lists/`date +%Y-%m-%d`"
mkdir -p $folder
for i in null com.google.android.packageinstaller com.android.vending dev.imranr.obtainium ru.vk.store; do
  pm list packages -i -3 | grep installer=$i | cut -d':' -f2 | awk '{printf "%s\n", $1}' > $folder/$i.txt
done
```

`adb pull /sdcard/Download/APKs/app_lists/`

- show other
  - `pm list packages -i -3 | grep -v installer=null | grep -v installer=com.google.android.packageinstaller | grep -v installer=com.android.vending | grep -v installer=dev.imranr.obtainium | grep -v installer=ru.vk.store`

### persist WiFi ADB

- shizuku
  - Phone TODO
    - [1](https://www.reddit.com/r/tasker/comments/1j7n1em/project_silently_start_adb_on_boot_without_root/?utm_medium=web3x&utm_term=1)
    - [2](https://www.reddit.com/r/tasker/comments/re8k68/howto_enable_adb_wifi_after_reboot_using_ladb_app/)
    - [3](https://www.reddit.com/r/tasker/comments/rceljk/enable_adb_wifi_on_device_boot_android_11/)
  - PC
    - `IP=192.168.1.7`
    - `adb connect $IP:$(nmap $IP -p 33000-46000 | awk "/\/tcp/" | cut -d/ -f1)`
      - [credits](https://stackoverflow.com/a/70878705)
- root
  - Phone
    - enable `setprop persist.adb.tcp.port 5555 && stop adbd && start adbd`
    - disable `resetprop -d persist.adb.tcp.port && stop adbd && start adbd`
  - PC `adb connect 192.168.1.7:5555`

### adbfs-fuse

```sh
umount /run/media/$USER/adbfs; adb kill-server && adb connect 192.168.1.7:5555 && sudo mkdir -p /run/media/$USER/adbfs/ && sudo chown $(id -u):$(id -g) /run/media/$USER/adbfs/ && adbfs /run/media/$USER/adbfs -o uid=$(id -u),gid=$(id -g)
```

### TODO

- `ADB_DELAYED_ACK=1` [when adb is used for large files transfer](https://developer.android.com/tools/adb#burstMode)

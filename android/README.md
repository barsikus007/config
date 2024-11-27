# [Android](../README.md)

## Instructions

### [YouTube ReVanced](revanced.md)

### [Termux](termux.md)

### [Root](root.md)

## Devices

### [Oculus Quest 2](devices/oculus.md)

### [Mi TV Stick](devices/mitv.md)

### [Pixel 7 Pro](https://4pda.to/forum/index.php?showtopic=1039682)

#### Useful topics

- [root and kernel english](https://xdaforums.com/t/november-12-2023-up1a-231105-003-a1-for-jp-carriers-unlock-bootloader-root-pixel-7-pro-cheetah-safetynet.4502805/)
- OTA
  - [Without PC](https://github.com/topjohnwu/Magisk/blob/master/docs/ota.md#devices-with-ab-partitions)
  - [Pixel Flasher](https://github.com/badabing2005/PixelFlasher/releases)
  - [root update russian](https://4pda.to/forum/index.php?s=&showtopic=1063306&view=findpost&p=120901180)

#### backup apps list

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

#### TODO

- Design and Tweak Mods
  - <https://github.com/Mahmud0808/Iconify>

#### DEPRECATED

- Audio. Because no configuration and no difference.
  - [ViPERFX RE](https://github.com/AndroidAudioMods/ViPERFX_RE)
  - [ViPER4Android Repackaged](https://github.com/programminghoch10/ViPER4AndroidRepackaged)
  - [?Dolby Atmos](https://gitlab.com/reiryuki-the-fixer/dolby-atmos-magic-revision-magisk-module)
  - [no root - wavelet](https://4pda.to/forum/index.php?showtopic=1039682&view=findpost&p=119899326)

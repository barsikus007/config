# [Root](./)

## ~~Magisk~~ ~~[KernelSU](https://github.com/tiann/KernelSU/releases)~~ [APatch](https://github.com/bmax121/APatch/releases) Modules

- Essential
  - [Zygisk**Next**](https://github.com/Dr-TSNG/ZygiskNext/releases)
  - [LSPosed](https://github.com/JingMatrix/LSPosed/releases)
    - /data/adb/lspd/config
- Hiding root
  - [Zygisk-Assistant](https://github.com/snake-4/Zygisk-Assistant/releases)
  - [Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases)
  - [Play Integrity Fix](https://github.com/chiteroman/PlayIntegrityFix/releases)
    - [playcurl](https://github.com/daboynb/PlayIntegrityNEXT/releases)
      - !dont used
    - [Play Integrity Fork](https://github.com/osm0sis/PlayIntegrityFork/releases)
      - !dont used
- Fixes
  - [volte](https://xdaforums.com/t/mod-magisk-root-volte-enabler.4372705/)
  - [pixel-mdm-patch](https://github.com/andrewz1/pixel-mdm-patch/releases)
    - don't work on latest firmware/kernelsu
- Interface
  - [Noto Emoji PLUS](https://www.patreon.com/RKBDI) [[Telegram](https://t.me/rkbdiemoji)]
  - [Monet Icons](https://github.com/Syoker/extra-themed-icons/releases)
    - TeamFiles Icons
  - [PixelXpert](https://github.com/siavash79/PixelXpert/releases)
    - Miscellaneous
      - Launcher options
        - Auto-generate missing themed icons
    - Then disble this unstable thing
    - Other useful fixes
      - Can disable camera cutout
  - [HideNavBar](https://github.com/Magisk-Modules-Alt-Repo/HideNavBar/releases)
    - !dont used
    - !setup is outdated
    - Immersive
    - Yes > Hide Pill and keep keyboard height/space
    - Yes > Hide keyboard buttons
    - No > Reduce the size of the keyboard bar
    - Low sensitivity
    - No > GCam fix
    - No > Disable back gestures
- [BCR](https://github.com/chenxiaolong/BCR/releases)
  - root to app
  - Settings
    - Call recording
    - Output directory
      - Android/media/bcr
  - Silent notifications
- [DriveDroid](https://github.com/overzero-git/DriveDroid-fix-Magisk-module/releases)
  - [Latest version (only RUS)](https://4pda.to/forum/index.php?showtopic=915158&view=findpost&p=121164720)
- [Pixelify](https://github.com/Kingsman44/Pixelify)
  - [Google-Photos-Unlimited-backup Submodule](https://www.pling.com/p/2004615/)

## LSPosed Modules

- [Flag Secure Hax](https://github.com/Xposed-Modules-Repo/com.varuns2002.disable_flag_secure)
- [AlfaBank Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.alfabankpatcher)
- [SberBank Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.sberbankpatcher)
- [MirPay Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.mirpaysecurity)

## Apps

- [Swift Backup](https://play.google.com/store/apps/details?id=org.swiftapps.swiftbackup)
- [Card emulation](https://play.google.com/store/apps/details?id=com.yuanwofei.cardemulator.pro)
- [VPN Hotspot](https://play.google.com/store/apps/details?id=be.mygod.vpnhotspot) [[GitHub](https://github.com/Mygod/VPNHotspot/releases)]
- [Classic Power Menu](https://github.com/KieronQuinn/ClassicPowerMenu/releases)
- [DPI](https://github.com/nomoresat/DPITunnel-android/releases)
- [KernelFlasher](https://github.com/capntrips/KernelFlasher/releases)
  - [KernelSU fix](https://github.com/capntrips/KernelFlasher/releases/tag/v1.0.0-alpha20%2Ballow-errors)
- [TODO](https://github.com/stars/barsikus007/lists/neckbeard-android)

## HBM

```su
echo 2 >> /sys/class/backlight/panel0-backlight/hbm_mode
```

- `/sys/class/backlight/panel0-backlight/`
  - `hbm_mode`
    - 0 - off
    - 1 - hdr
    - 2 - sun
  - `brightness`
    - up to 2047 for hbm 0
    - up to 4095 for hbm 2
  - `local_hbm_mode` ? 0
  - `local_hbm_max_timeout` ? 300

### References

- <https://www.xda-developers.com/google-pixel-4-high-brightness-mode-fix/>
- <https://xdaforums.com/t/hbm.4356189/>
- <https://play.google.com/store/apps/details?id=com.franco.kernel>

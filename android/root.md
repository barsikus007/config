# [Root](./)

## ~~Magisk~~ ~~[KernelSU](https://github.com/tiann/KernelSU)~~ [APatch](https://github.com/bmax121/APatch) ~~[Kitsune Magisk](https://github.com/1q23lyc45/KitsuneMagisk)~~ ~~[KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next)~~

### ඞ installation

1. Kernel Flasher fork
2. [ඞ kernel](https://github.com/WildKernels/GKI_KernelSU_SUSFS/releases)
   - P7 A15 is `6.1.99-android14`
   - P7 A16 is `6.1.124-android14`
   - P7 A16 is `6.1.134-android14`
   - [OnePlus specific](https://github.com/WildKernels/OnePlus_KernelSU_SUSFS/releases)
3. [ඞ module](https://github.com/sidex15/susfs4ksu-module/releases)

#### OTA

1. Start system update
2. Wait until "Restart Now" button
3. Flash AnyKernel.zip to inactive slot from above repo with Kernel Flasher
   1. Check inactive slot's kernel version
4. Press "Restart Now" button

### Modules

- Essential
  - ~~[Zygisk**Next**](https://github.com/Dr-TSNG/ZygiskNext/releases)~~ ~~[ReZygisk](https://github.com/PerformanC/ReZygisk/releases)~~ [NeoZygisk](https://github.com/JingMatrix/NeoZygisk/releases)
  - [LSPosed](https://github.com/JingMatrix/LSPosed/releases)
    - [temp fix](https://github.com/JingMatrix/LSPosed/actions/runs/17713071813)
    - `/data/adb/lspd/config`
- [Hiding root](https://github.com/sidex15/susfs4ksu-module/issues/39#issuecomment-3080237450)
  - Integrity
    - ~~[Play Integrity Fix](https://github.com/chiteroman/PlayIntegrityFix/releases)~~ [Fork](https://github.com/osm0sis/PlayIntegrityFork/releases)
      - Action
    - [Tricky Store](https://github.com/5ec1cff/TrickyStore)
      - TODO: FOSS forks
        - <https://github.com/qwq233/TrickyStore>
        - <https://github.com/beakthoven/TrickyStoreOSS>
    - [Tricky Addon - Update Target List](https://github.com/KOWX712/Tricky-Addon-Update-Target-List)
      - Menu
        - Select All
        - Deselect Unnecessary
        - Set Valid Keybox
        - Set Security Patch
      - Save
    - [TSupport](https://github.com/citra-standalone/Citra-Standalone)
      - !dont used
- Fixes
  - [volte](https://xdaforums.com/t/mod-magisk-root-volte-enabler.4372705/)
  - [pixel-mdm-patch](https://github.com/andrewz1/pixel-mdm-patch/releases)
    - !don't work on latest firmware/kernelsu
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
- ~~[Pixelify](https://github.com/Kingsman44/Pixelify/releases)~~
- [Google-Photos-Unlimited-backup Submodule](https://git.disroot.org/cuynu/gphotos-unlimited-zygisk/releases)
- [bindhosts](https://github.com/bindhosts/bindhosts/releases)
  - [rule](https://4pda.to/forum/index.php?showtopic=915158&view=findpost&p=133873426)

## LSPosed Modules

- [Flag Secure Hax](https://github.com/Xposed-Modules-Repo/com.varuns2002.disable_flag_secure)
- [AlfaBank Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.alfabankpatcher)
- [SberBank Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.sberbankpatcher)
- ~~[MirPay Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.mirpaysecurity)~~ [PaySecurityBypass](https://github.com/vova7878-modules/PaySecurityBypass)
- [allow downgrade](https://github.com/LSPosed/CorePatch)

## Apps

- Kernel Flasher fork - `https://github.com/fatalcoder524/KernelFlasher`
- [Swift Backup](https://play.google.com/store/apps/details?id=org.swiftapps.swiftbackup)
- [Card emulation](https://play.google.com/store/apps/details?id=com.yuanwofei.cardemulator.pro)
- [VPN Hotspot](https://play.google.com/store/apps/details?id=be.mygod.vpnhotspot)  - `https://github.com/Mygod/VPNHotspot`
- Classic Power Menu - `https://github.com/KieronQuinn/ClassicPowerMenu`
  - TODO: module for OnePlus
- Root Detector - `https://github.com/reveny/Android-Native-Root-Detector`
  - [another one - momo](https://t.me/magiskalpha/529)
- Hide Applists - `https://github.com/frknkrc44/HMA-OSS`
  - Checker - `https://github.com/Dr-TSNG/ApplistDetector`
- [TODO](https://github.com/stars/barsikus007/lists/neckbeard-android)
  - [cool boot animation](https://github.com/Chainfire/liveboot)
    - I prefer Pixel's stock one

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

# [root](./)

## [APatch](https://github.com/bmax121/APatch) ~~[KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next)~~

with [hybrid_mount](https://github.com/Hybrid-Mount/meta-hybrid_mount) metamodule

### ඞ installation

1. Kernel Flasher fork
2. [ඞ kernel](https://github.com/WildKernels/GKI_KernelSU_SUSFS/releases)
   - P7 A15 is `6.1.99-android14`
   - P7 A16 is `6.1.124-android14`
   - P7 A16 is `6.1.134-android14`
   - [OnePlus specific](https://github.com/WildKernels/OnePlus_KernelSU_SUSFS/releases)
3. [ඞ module](https://github.com/sidex15/susfs4ksu-module/releases)

#### OTA

1. start system update
2. wait until "Restart Now" button
3. flash AnyKernel.zip to inactive slot from above repo with Kernel Flasher
   1. check inactive slot's kernel version
4. press "Restart Now" button

### modules

- essential
  - [NeoZygisk](https://github.com/JingMatrix/NeoZygisk/releases)
  - [Vector aka LSPosed](https://github.com/JingMatrix/Vector/releases)
    - `/data/adb/lspd/config`
- [hiding root](https://github.com/sidex15/susfs4ksu-module/issues/39#issuecomment-3080237450)
  - integrity
    - [Play Integrity Fork](https://github.com/osm0sis/PlayIntegrityFork/releases)
      - Action
    - [TEESimulator-RS](https://github.com/Enginex0/TEESimulator-RS/releases)
      - [Tricky Addon Enhanced](https://github.com/Enginex0/tricky-addon-enhanced/releases)
      - [Yurikey Manager](https://github.com/Yurii0307/yurikey/releases)
- fixes
  - [volte](https://xdaforums.com/t/mod-magisk-root-volte-enabler.4372705/)
- interface
  - [Noto Emoji PLUS](https://www.patreon.com/RKBDI) [[Telegram](https://t.me/rkbdiemoji)]
  - [Monet Icons](https://github.com/Syoker/extra-themed-icons/releases)
    - TeamFiles Icons
  - [PixelXpert](https://github.com/siavash79/PixelXpert/releases)
    - Miscellaneous
      - Launcher options
        - Auto-generate missing themed icons
    - then disble this unstable thing
    - other useful fixes
      - can disable camera cutout
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
- [Pixelify](https://github.com/BasGame1/Pixelify-Next/releases)
  - !dont used
- [Google-Photos-Unlimited-backup Submodule](https://git.disroot.org/cuynu/gphotos-unlimited-zygisk/releases)
- [bindhosts](https://github.com/bindhosts/bindhosts/releases)
  - [rule](https://4pda.to/forum/index.php?showtopic=915158&view=findpost&p=133873426)
- [App Network Firewall](https://github.com/Rem01Gaming/net-switch/releases)

## LSPosed Modules

- [Flag Secure Hax](https://github.com/Xposed-Modules-Repo/com.varuns2002.disable_flag_secure)
- [AlfaBank Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.alfabankpatcher)
- [SberBank Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.sberbankpatcher)
- ~~[MirPay Patcher](https://github.com/Xposed-Modules-Repo/ru.bluecat.mirpaysecurity)~~ [PaySecurityBypass](https://github.com/vova7878-modules/PaySecurityBypass)
- [allow downgrade](https://github.com/LSPosed/CorePatch)

## apps

- Kernel Flasher fork - `https://github.com/fatalcoder524/KernelFlasher`
- [Swift Backup](https://play.google.com/store/apps/details?id=org.swiftapps.swiftbackup)
- [Card emulation](https://play.google.com/store/apps/details?id=com.yuanwofei.cardemulator.pro)
- [VPN Hotspot](https://play.google.com/store/apps/details?id=be.mygod.vpnhotspot)  - `https://github.com/Mygod/VPNHotspot`
- Classic Power Menu - `https://github.com/KieronQuinn/ClassicPowerMenu`
  - TODO: module for OnePlus
- Root Detector - `https://github.com/reveny/Android-Native-Root-Detector`
- Hide Applists - `https://github.com/frknkrc44/HMA-OSS`
  - checker - `https://github.com/Dr-TSNG/ApplistDetector`
- [cool boot animation](https://github.com/Chainfire/liveboot)
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

### references

- <https://www.xda-developers.com/google-pixel-4-high-brightness-mode-fix/>
- <https://xdaforums.com/t/hbm.4356189/>
- <https://play.google.com/store/apps/details?id=com.franco.kernel>

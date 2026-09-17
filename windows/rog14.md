# [ASUS GA401IV](./)

- windows power
  - RestartGPU (run as root)
    - `$device = Get-PnpDevice | Where-Object { $_.FriendlyName -imatch 'NVIDIA' -and $_.Class -eq 'Display' }; Disable-PnpDevice $device.InstanceId -Confirm:$false; Start-Sleep -Seconds 3; Enable-PnpDevice $device.InstanceId -Confirm:$false`
  - Power Options
    - Switchable Dynamic Graphics
      - Global Settings
        - On battery: Force power-saving graphics
  - unlock hidden power functions
    - `powercfg.exe -attributes sub_processor perfboostmode -attrib_hide`
    - `powercfg.exe -attributes sub_disk 0b2d69d7-a2a1-449c-9680-f91c70521c60 -attrib_hide`
- ROG G14 [AniMe](https://rog.asus.com/content/anime-vision-pixel-editor/#editor)
  - <https://drive.google.com/drive/u/0/folders/1_FsWd2CAjAK13t82ZucTlNGabuI3laWF>
  - <https://blog.joshwalsh.me/asus-anime-matrix/>
  - <https://github.com/IAmSuyogJadhav/Anime-Matrix>
- [ROG Fonts v1.5](https://dlcdnets.asus.com/pub/ASUS/GamingNB/AppforWin10/ROGFont/Font_ROG_ASUS_V100.zip?model=ROG%20Zephyrus%20G14)

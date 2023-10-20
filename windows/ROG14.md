# [ASUS GA401IV](./)
## TODO
- https://www.reddit.com/r/ZephyrusG14/comments/p63yct/how_do_i_disable_varibright_without_using_radeon/
- https://www.reddit.com/r/ZephyrusG14/comments/hldxcv/how_to_get_10_hours_battery/
- https://discord.com/channels/736971456054952027/736971456650412114/784252533886418954
- https://github.com/aredden/RestartGPU/
- https://github.com/sammilucia/ASUS-G14-Debloating/
- https://drive.google.com/file/d/1tsmKRIt1S2AUqp3S2pFVCtBNxXtQC3bE/view
- unlock hidden power functions
  - unknown source (reddit)
  - `powercfg.exe -attributes sub_processor perfboostmode -attrib_hide`
  - `powercfg.exe -attributes sub_disk 0b2d69d7-a2a1-449c-9680-f91c70521c60 -attrib_hide`
- ROG G14 AniMe
  - https://drive.google.com/drive/u/0/folders/1_FsWd2CAjAK13t82ZucTlNGabuI3laWF
  - https://blog.joshwalsh.me/asus-anime-matrix/
  - https://rog.asus.com/anime-matrix-pixel-editor/?device=DS-Animate#editor
- RestartGPU (Run as root)
  - `$device = Get-PnpDevice | Where-Object { $_.FriendlyName -imatch 'NVIDIA' -and $_.Class -eq 'Display' }; Disable-PnpDevice $device.InstanceId -Confirm:$false; Start-Sleep -Seconds 3; Enable-PnpDevice $device.InstanceId -Confirm:$false`

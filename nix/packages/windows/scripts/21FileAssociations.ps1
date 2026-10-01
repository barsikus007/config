if (-not $env:SCOOP) {
    throw "SCOOP environment variable is not set"
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DanysysTeam/PS-SFTA/master/SFTA.ps1'))

'.zip','.rar','.7z','.001','.arj','.bz2','.cab','.gz','.lzh','.tar','.xz','.z' | ForEach-Object {
    Register-FTA "$env:SCOOP\apps\7zip\current\7zFM.exe" $_ -ProgId "7-Zip$_" -Icon "$env:SCOOP\apps\7zip\current\7z.dll,1"
}

'.txt','.log','.ini','.cfg','.conf','.json','.xml','.yaml','.yml','.md','.csv','.ps1','.psm1','.inf','.css','.js','.ts','.cs','.py','.java','.cpp','.c','.h','.php','.sql' | ForEach-Object {
    Set-FTA Notepad++$_ $_
    Register-FTA "$env:SCOOP\apps\notepadplusplus\current\notepad++.exe" $_ -ProgId "Notepad++$_" -Icon "$env:SCOOP\apps\notepadplusplus\current\notepad++.exe,0"
}

'.jpg','.jpeg','.jpe','.png','.gif','.bmp','.tif','.tiff','.ico','.psd','.tga','.wmf','.emf','.webp','.heic','.avif' | ForEach-Object {
    Register-FTA "$env:SCOOP\apps\irfanview\current\i_view64.exe" $_ -ProgId "IrfanView$_" -Icon "$env:SCOOP\apps\irfanview\current\i_view64.exe,0"
}

$SCOOP_HOME = $(If (Test-Path env:SCOOP) { $env:SCOOP } Else { ($env:GIT_INSTALL_ROOT -split "scoop")[0]+"scoop" })

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DanysysTeam/PS-SFTA/master/SFTA.ps1'))

'.zip','.rar','.7z','.001','.arj','.bz2','.cab','.gz','.lzh','.tar','.xz','.z' | ForEach-Object {
    Register-FTA "$SCOOP_HOME\apps\7zip\current\7zFM.exe" $_ -ProgId "7-Zip$_" -Icon "$SCOOP_HOME\apps\7zip\current\7z.dll,1"
}

'.txt','.log','.ini','.cfg','.conf','.json','.xml','.yaml','.yml','.md','.csv','.ps1','.psm1','.bat','.cmd','.reg','.inf','.css','.js','.ts','.html','.htm','.cs','.py','.java','.cpp','.c','.h','.php','.sql' | ForEach-Object {
    Set-FTA Notepad++$_ $_
    Register-FTA "$SCOOP_HOME\apps\notepadplusplus\current\notepad++.exe" $_ -ProgId "Notepad++$_" -Icon "$SCOOP_HOME\apps\notepadplusplus\current\notepad++.exe,0"
}

$debugz = $true
Function Debug-Log {
    Param(
        [Parameter(ValueFromPipeline)]$item,
        [Parameter(mandatory=$false, ValueFromRemainingArguments=$true)]$args
    )
    if ($debugz) {
        Write-Host $item $args
    }
}

# https://github.com/PowerShell/PSReadLine/issues/1992#issuecomment-1525427107
function IsVirtualTerminalProcessingEnabled {
	$MethodDefinitions = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
'@
	$Kernel32 = Add-Type -MemberDefinition $MethodDefinitions -Name 'Kernel32' -Namespace 'Win32' -PassThru
	$hConsoleHandle = $Kernel32::GetStdHandle(-11) # STD_OUTPUT_HANDLE
	$mode = 0
	$Kernel32::GetConsoleMode($hConsoleHandle, [ref]$mode) >$null
	if ($mode -band 0x0004) { # 0x0004 ENABLE_VIRTUAL_TERMINAL_PROCESSING
		return $true
	}
	return $false
}

function CanUsePredictionSource {
	return (! [System.Console]::IsOutputRedirected) -and (IsVirtualTerminalProcessingEnabled)
}


Debug-Log initial (Measure-Command {
if (! (CanUsePredictionSource)) { exit }
}).Milliseconds


Function Test-Command ($commandName) {
    if (Get-Command $commandName -ErrorAction SilentlyContinue) { return $true }
    return $false
}


Debug-Log starship (Measure-Command {
# https://starship.rs/
Invoke-Expression (&starship init powershell)
starship completions powershell | Out-String | Invoke-Expression
}).Milliseconds (Measure-Command {
Set-PSReadLineOption -PredictionSource History
# Set-PSReadlineOption -EditMode Vi
# Set-PSReadlineOption -EditMode Emacs
# https://stackoverflow.com/a/62936536/15844518
Set-PSReadLineOption -AddToHistoryHandler {
    param($command)
    if ($command -like ' *') {
        return $false
    }
    # Add any other checks you want
    return $true
}
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }  # TODO bugged
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}).Milliseconds


Debug-Log proto (Measure-Command {
# proto & go
$env:PROTO_HOME = Join-Path $HOME ".config" "proto"
$env:GOBIN = Join-Path $HOME "go" "bin"
$env:PATH = @(
    (Join-Path $env:PROTO_HOME "shims"),
    (Join-Path $env:PROTO_HOME "bin"),
    $env:GOBIN,
    $env:PATH
) -join [IO.PATH]::PathSeparator
}).Milliseconds


Debug-Log aliases (Measure-Command {
# init
$env:BAT_PAGER="less -rF --mouse"
$env:BAT_THEME="Coldark-Dark"
Set-Alias -Option AllScope cat bat
Function Get-Full-History { bat (Get-PSReadlineOption).HistorySavePath -l powershell }
Set-Alias -Option AllScope history Get-Full-History
Set-Alias -Option AllScope editor nvim

# base
Function grep { grep.exe --color=auto $args }
# FUCK PWSH
Function grp { grep.exe --color=auto -Fin -C 7 $args }
Function c { clear }
Set-Alias -Option AllScope h history
# FUCK PWSH
Function hf { h | grep.exe --color=auto -Fin -C 7 $args }
Function sshe { editor $HOME\.ssh\config }
Test-Path Alias:\nv && Remove-Item Alias:\nv
Function nv { editor $(fzf) }
Function 1ip { wget -qO - icanhazip.com }
Function 2ip { curl 2ip.ru }

# ls
Function l { ls -CF $args }
Function ll { ls -la $args }
# TODO: lazy pwsh: function first time resolver
if (Test-Command eza) {
    Set-Alias -Option AllScope ls eza
    # TODO fix command args
    Function l { eza -F -bghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink $args }
    Function ll { eza -F -labghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink $args }
}

# package managers and updaters
Function suss { scoop update | scoop status }
Function i { scoop install }
Function u { suss | scoop update * }
Function cu { cd ~/config/ && git pull && ./configs/install.ps1 && ./windows/pwsh.ps1 && cd - }

# docker
Function lzd { lazydocker }
Function lzdu { scoop update lazydocker }
Function dc { docker compose $args }
Function dsp { docker system prune $args }
Function dspa { dsp --all $args }
Function dcu { dc up -d $args }
Function dcub { dc up -d --build $args }
Function dcuo { dc up -d --remove-orphans $args }
Function dcup { dc -f compose.prod.yaml up -d }
Function dcp { dc ps $args }
Function dcs { dc stop $args }
Function dcd { dc down $args }
Function dcl { dc logs $args }
Function dcr { dc restart $args }
Function dce { docker compose exec -it $args }
Function dcsh { dce $args sh -c 'bash || sh' }

# python
Function pyvcr { python3 -m venv .venv --upgrade-deps && .venv/Scripts/python -c "import sys,pathlib;v=sys.version_info;pyv=f'{v.major}.{v.minor}';path=pathlib.Path('.venv/pyvenv.cfg');path.write_text(path.read_text(encoding='utf-8').replace(f'{v.major}.{v.minor}.{v.micro}',pyv).replace(f'{pyv}\\','current\\'),encoding='utf-8')" && .venv/Scripts/Activate.ps1 && .venv/Scripts/pip install -r requirements.txt }
Function pyv { .venv/Scripts/Activate.ps1 || (pyvcr) }
Function pyt { ptpython --asyncio }
Function pipi { python -c "import os;os.environ['VIRTUAL_ENV']" && pip install -r requirements.txt || echo "activate venv to install requirements" }

# other
Function sex { explorer.exe . }
}).Milliseconds


Debug-Log autocompletions (Measure-Command {
Invoke-Expression (&scoop-search --hook)
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
Import-Module "gsudoModule"
Invoke-Expression (& { (proto completions | Out-String) })
if (Test-Command zoxide) {
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}
# https://github.com/microsoft/winget-cli/blob/master/doc/Completion.md
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
}).Milliseconds

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58


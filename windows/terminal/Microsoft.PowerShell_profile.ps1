$debug_load_time = $false
Function Debug-Log {
    Param(
        [Parameter(ValueFromPipeline)]$item,
        [Parameter(mandatory=$false, ValueFromRemainingArguments=$true)]$args
    )
    if ($debug_load_time) {
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
if ($PSVersionTable.PSVersion.Major -gt 5) {
	Set-PSReadLineOption -PredictionSource History
}
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
$env:PROTO_HOME = [IO.Path]::Combine($HOME, ".config", "proto")
$env:GOBIN = [IO.Path]::Combine($HOME, "go", "bin")
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
Function ssht { ssh $args -t "tmux new -As0 || bash || sh" }
#* Test-Path Alias:\nv && Remove-Item Alias:\nv -Force
#* Function nv { editor $(fzf) }
Function 1ip { wget -qO - icanhazip.com }
Function 2ip { curl 2ip.ru }
Function mkcd { New-Item $args -ItemType Directory -Force | Select-Object Name | Set-Location }

# ls
Function l { ls -CF $args }
Function ll { ls -la $args }
if (Test-Command eza) {
    Set-Alias -Option AllScope ls eza
    Function l { eza -F -bghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink $args }
    Function ll { eza -F -labghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink $args }
}

# package managers and updaters
Function suss { scoop update | scoop status }
Function i { scoop install }
Function u { suss | scoop update * }
#* Function cu { cd ~/config/ && git pull && ./configs/install.ps1 && ./windows/pwsh.ps1 && cd - }

# docker
$env:COMPOSE_BAKE=$true
Function lzd { lazydocker }
Function lzdu { scoop update lazydocker }
Function dc { docker compose $args }
Function dsp { docker system prune $args }
Function dspa { dsp --all $args }
Function dcu { docker compose up -d $args }
Function dcub { docker compose up -d --build $args }
Function dcuo { docker compose up -d --remove-orphans $args }
Function dcup { docker compose -f compose.prod.yaml up -d }
Function dcp { docker compose ps $args }
Function dcs { docker compose stop $args }
Function dcd { docker compose down $args }
Function dcl { docker compose logs $args }
Function dcr { docker compose restart $args }
Function dce { docker compose exec -it $args }
Function dcsh { dce $args sh -c 'bash || sh' }

# python
# TODO uv install alias?
# TODO uv resolve python version and write to PATH
#* Function pipi { uv pip install -r requirements.txt || uv pip install -r pyproject.toml }
#* Function pyvcr { uv venv --allow-existing && .venv\Scripts\activate && (pipi) }
#* Function pyv { .venv/Scripts/activate || (pyvcr) }
Function pyt { ptpython }
Function pyta { ptpython --asyncio }

# other
Function sex { explorer.exe . }
# https://yazi-rs.github.io/docs/quick-start/#shell-wrapper
Function yy {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}
}).Milliseconds


Debug-Log autocompletions (Measure-Command {
Invoke-Expression (&scoop-search --hook)
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
Import-Module "gsudoModule"
if (Test-Command proto) {
    Invoke-Expression (& { (proto completions | Out-String) })
}
if (Test-Command zoxide) {
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}
if (Test-Command uv) {
    Invoke-Expression (& { (uv generate-shell-completion powershell | Out-String) })
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

if (Get-Module -Name Microsoft.WinGet.CommandNotFound) {
    Import-Module -Name Microsoft.WinGet.CommandNotFound
}
#f45873b3-b655-43a6-b217-97c00aa0db58


# terminate if powershell version is less than 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Limited profile loaded" -ForegroundColor Red
    Write-Host "PowerShell version 7 or higher is required" -ForegroundColor Red
    Write-Host "winget install -e --id Microsoft.PowerShell" -ForegroundColor DarkGray
    exit
} else {
    ~\Documents\PowerShell\extend.ps1 | Out-Null
}

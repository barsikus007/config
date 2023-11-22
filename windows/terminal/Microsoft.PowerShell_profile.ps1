$debugz = $true
Function Debug-Log {
    Param(
        [Parameter(ValueFromPipeline)]
        $item
    )
    if ($debugz) {
        Write-Host $item$args
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

Debug-Log initial
(Measure-Command {
if (! (CanUsePredictionSource)) { exit }
}).Milliseconds | Debug-Log
Function Test-Command ($commandName) {
    if (Get-Command $commandName -ErrorAction SilentlyContinue) { return $true }
    return $false
}


Debug-Log starship
(Measure-Command {
# https://starship.rs/
Invoke-Expression (&starship init powershell)
starship completions powershell | Out-String | Invoke-Expression
}).Milliseconds | Debug-Log

(Measure-Command {
Set-PSReadLineOption -PredictionSource History
# Set-PSReadlineOption -EditMode Vi
# Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }  # TODO bugged
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}).Milliseconds | Debug-Log


Debug-Log aliases
(Measure-Command {
Set-Alias -Option AllScope cat bat
Function Get-Full-History { cat (Get-PSReadlineOption).HistorySavePath -l powershell }
Set-Alias -Option AllScope history Get-Full-History
Function suss { scoop update | scoop status }

Function grep { grep.exe --color=auto $args }
# FUCK PWSH
Function grp { grep.exe --color=auto -Fin -C 7 $args }
Function c { clear }
Set-Alias -Option AllScope h history
# FUCK PWSH
Function hf { h | grep.exe --color=auto -Fin -C 7 $args }
if (Test-Command eza) {
    Set-Alias -Option AllScope ls eza
    # TODO fix command args
    Function ll { eza -laFbghM --smart-group --group-directories-first --color=always --color-scale --icons=always --no-quotes --hyperlink --git --git-repos $args }
    Function l { eza -FbghM --smart-group --group-directories-first --color=always --color-scale --icons=always --no-quotes --hyperlink $args }
}
Function l { ls -CF $args }
Function ll { ls -la $args }
Function u { suss | scoop update * }

Function cu { (cd ~/config/) -and (git pull) -and (./configs/install.ps1) -and (./windows/pwsh.ps1) -and (cd -) }

Function lzd { lazydocker }

Function dc { docker compose $args }
Function dcu { dc up -d --build $args }
Function dcp { dc ps $args }
Function dcs { dc stop $args }
Function dcd { dc down $args }
Function dcl { dc logs $args }
Function dcr { dc restart $args }
Function dce { dc exec -it $args }
}).Milliseconds | Debug-Log


Debug-Log autocompletions
(Measure-Command {
Invoke-Expression (&scoop-search --hook)
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
Import-Module "gsudoModule"
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
}).Milliseconds | Debug-Log

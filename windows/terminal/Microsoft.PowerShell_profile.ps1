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

if (! (CanUsePredictionSource)) { exit }


# https://starship.rs/
Invoke-Expression (&starship init powershell)
starship completions powershell | Out-String | Invoke-Expression

# too slow
# Import-Module terminal-icons

Set-PSReadLineOption -PredictionSource History
# Set-PSReadlineOption -EditMode Vi
# Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }  # TODO bugged
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'


# autocompletions
Invoke-Expression (&scoop-search --hook)
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
Import-Module "gsudoModule"

# aliases
Function suss {scoop update | scoop status}
Function ll { ls }
Function c { clear }
Function h { History }

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

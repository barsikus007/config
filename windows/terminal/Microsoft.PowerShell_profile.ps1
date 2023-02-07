# https://starship.rs/
Invoke-Expression (&starship init powershell)
starship completions powershell | Out-String | Invoke-Expression

# too slow
# Import-Module terminal-icons

Set-PSReadLineOption -PredictionSource History
# Set-PSReadlineOption -EditMode Vi
# Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key ctrl+d -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'


# autocompletions
Invoke-Expression (&scoop-search --hook)
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"

# aliases
Function suss {scoop update | scoop status}

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

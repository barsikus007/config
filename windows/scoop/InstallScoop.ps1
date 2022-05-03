if ($args[0]) {
    $ScoopDir = $args[0]
    echo Run:
    echo "iwr -useb get.scoop.sh -outfile 'install.ps1'; .\install.ps1 -ScoopDir $ScoopDir; rm install.ps1"
    echo Then
    exit
} else {
    $ScoopDir = "~\scoop"
    iwr -useb get.scoop.sh | iex
}
echo 'Reload terminal and run:'
echo "$PSScriptRoot\InstallSoft.ps1"

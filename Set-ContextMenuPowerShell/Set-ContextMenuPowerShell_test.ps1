$AddRegValues = @(
    @(
        'Open Windows PowerShellx86 as Administrator',
        "c:\Windows\syswow64\powershell.exe -NoExit -NoProfile -Command ""Set-Location '%V'""",
        "PowerShellx86"
    ),
    @(
        'Open Windows PowerShellx64 as Administrator',
        "$PSHOME\powershell.exe -NoExit -NoProfile -Command ""Set-Location '%V'""",
        "PowerShellx64"
    )
) | %{
    [PSCustomObject]@{
        ContextMenus = $_[0]
        commands = $_[1]
        versions = $_[2]
    }
}

$RegKeys = @(
    "directory",
    "directory\background",
    "drive"
)

foreach ($RegKey in $RegKeys){

    $AddRegValues | %{
        $ContextMenu = $_.ContextMenus
        $command = $_.commands
        $version = $_.versions

        New-Item -Path "Registry::HKEY_CLASSES_ROOT\$RegKey\shell" -Name runas\command -Force `
            | Set-ItemProperty -Name "(default)" -Value $command -PassThru `
            | Set-ItemProperty -Name "icon" -Value "C:\Windows\System32\imageres.dll,-78" -PassThru `
            | Set-ItemProperty -Path {$_.PSParentPath} -Name '(default)' -Value $ContextMenu -PassThru `
            | Set-ItemProperty -Name HasLUAShield -Value ''
    }

}
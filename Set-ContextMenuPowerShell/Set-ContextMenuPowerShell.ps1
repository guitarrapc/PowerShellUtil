#Requires -Version 3.0

function Set-ElevatedContextMenu{

    param(
    [ValidateNotNullorEmpty()]
    [PSCustomObject]
    $AddRegValues = $null
    )

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
                | Set-ItemProperty -Path {$_.PSParentPath} -Name '(default)' -Value $ContextMenu -PassThru `
                | Set-ItemProperty -Name HasLUAShield -Value ''
        }
    }

}

$AddRegValues = [PSCustomObject]@{
    ContextMenus = "Open Windows PowerShellx64 as Administrator"
    commands = "$PSHOME\powershell.exe -NoExit -NoProfile -Command ""Set-Location '%V'"""
    versions = "PowerShellx64"
}

Set-ElevatedPowerShellContextMenu -AddRegValues $AddRegValues
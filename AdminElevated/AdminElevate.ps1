#Requires -Version 2.0

param(
    [string]$command="Show-WindowsDeveloperLicenseRegistration"
)

function Invoke-Admin() {
    param (
        [string]$Argument = "",
        [switch]$WaitForExit
    )

    $elevatedPS = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
    $elevatedPS.Arguments = $Argument
    $elevatedPS.Verb = "runas"
    $elevatedPS = [Diagnostics.Process]::Start($elevatedPS)
    
    if($waitForExit) 
    {
        $elevatedPS.WaitForExit();
    }
}

Invoke-Admin -Argument $command -waitForExit
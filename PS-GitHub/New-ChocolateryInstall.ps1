#Requires -Version 3.0

function New-ChocolateryInstall {

    param(
    [bool]$ShowMan=$false
    )

    Write-Host "Checking for chocolatery installation."

    try
    {
        Import-Module C:\Chocolatey\chocolateyinstall\helpers\chocolateyInstaller.psm1
    }
    catch
    {
        Invoke-Expression ((new-object Net.Webclient).DownloadString("http://bit.ly/psChocInstall"))
    }

    if (!(Get-Module chocolateyInstaller))
    {
        Invoke-Expression ((new-object Net.Webclient).DownloadString("http://bit.ly/psChocInstall"))
    }
    else
    {
        Write-Host "chocolatery had already been installed. nothing will do." -ForegroundColor Green
    }

    switch ($true){
    $ShowMan {Get-ChocolateryInstructions}
    default{ Write-Host "    - If you want to check simple chocolatery usage, add -ShowMan $true." -ForegroundColor Yellow}
    }

}
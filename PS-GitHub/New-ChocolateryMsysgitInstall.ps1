#Requires -Version 3.0

function New-ChocolateryMsysgitInstall {

    Write-Host "Checking for msysgit installation."

    if (!(Get-ChildItem -path "C:\Chocolatey\lib" -Recurse -Directory | ? {$_.Name -like "msysgit*"}))
    {
        cinst msysgit
    }
    else
    {
        Write-Host "msysgit had already been installed. nothing will do." -ForegroundColor Green
    }

}
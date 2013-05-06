#Requires -Version 3.0

function New-ChocolaterPoshGitInstall{

    Write-Host "Checking for install PoshGit."

    if (!(Get-ChildItem -path "C:\Chocolatey\lib" -Recurse -Directory | ? {$_.Name -like "Poshgit*"}))
    {
        cinst poshgit
    }
    else
    {
        Write-Host "PoshGit had already been installed. nothing will do." -ForegroundColor Green
    }

}
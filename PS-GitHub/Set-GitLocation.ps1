#Requires -Version 3.0

function Set-GitLocation{

    param(
    [string]
    $GitHomePath=$(Join-Path $(Join-Path "$env:HOMEDRIVE" "$env:HOMEPATH") $(Join-Path "Documents" "GitHub"))
    )

    Write-Host "Change current directory to $GitHomePath" -ForegroundColor Green
    Set-Location -Path $GitHomePath

    Write-Host "Git Directories in your home." -ForegroundColor Green
    Get-ChildItem

}
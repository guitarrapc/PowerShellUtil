#Requires -Version 3.0

function Set-EnvGitPath{

    Write-Host "Adding Git path for PowerShell Command."

    if (!($env:path -match "C:\\Program Files \(x86\)\\git\\bin\\;"))
    {
        $Env:Path += ";C:\Program Files (x86)\Git\bin\"
        Write-Host 'git path "C:\Program Files (x86)\Git\bin\" had been added to PATH.' -ForegroundColor Green
    }
    else
    {
        Write-Host 'git path "C:\Program Files (x86)\Git\bin\" had already been added to PATH. nothing will do.' -ForegroundColor Green
    }
}
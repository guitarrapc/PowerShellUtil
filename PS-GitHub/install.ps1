#Requires -Version 2.0

[CmdletBinding()]
Param(
    [Parameter(
    Position=0,
    Mandatory=$false,
    ValueFromPipeline=$True)]
    [string]
    $path=$(Split-Path $PSCommandPath -Parent)
)
      
Function Get-OperatingSystemVersion{
    (Get-WmiObject -Class Win32_OperatingSystem).Version
}

Function Test-ModulePath{

    $Path = "$env:userProfile\documents\WindowsPowerShell\Modules"
 
    Write-Verbose "Checking Module Home."
    if ([int](Get-OperatingSystemVersion).substring(0,1) -ge 6) 
    { 
        if(-not(Test-Path -path $Path))
        {
            Write-Verbose "Creating Module Home at $path"
            New-Item -Path $Path -itemtype directory > $null
        }
        else
        {
            Write-Verbose "$path found. Never create Module Direcoty and end Test-ModulePath function."
        }
    }

}

Function Copy-Module{
    
    param(
    [string]
    $name
    )

    $UserPath = $env:PSModulePath.split(";")[0]
    $global:ModulePath = Join-Path -path $userPath -childpath $(Get-Item $PSCommandPath).Directory.Name

    If(-not(Test-Path -path $modulePath))
    {
        Write-Verbose "Creating Custom Module Firectory at $ModulePath"
        New-Item -path $ModulePath -itemtype directory > $null

        try
        {
            Write-Verbose "Copying modules into $ModulePath"
            Copy-item -path $name -destination $ModulePath > $null
        }
        catch
        {
            Write-Warning "Copying error, Please check failed item. If you can, please copy it to $ModulePath"
        }
        finally
        {
        }
    }
    Else
    { 
        Write-Verbose "Copying modules into $ModulePath"
        try
        {
            Copy-item -path $name -destination $ModulePath > $null
        }
        catch
        {
            Write-Warning "Copying error, Please check failed item. If you can, please copy it to $ModulePath"
        }
        finally
        {
        }
    }
}

Write-Host "Starting checking Module path and Copy PowerShell Scripts job." -ForegroundColor Green

Write-Host "Checking Module Path existing." -ForegroundColor Green
Test-ModulePath

Write-Host "Copying Modules to Module Path." -ForegroundColor Green
Get-ChildItem -Path $path -File -Recurse `
    | where {$_.Extension -eq ".ps1" -or ".psm1" -or ".psd1"} `
    | Foreach-Object { 
        Write-Verbose "Copying $($_.fullName) to $path ."
        Copy-Module -name $_.fullName  
        }

Write-Host "Installation finished. Your Module Path is $ModulePath" -ForegroundColor Green

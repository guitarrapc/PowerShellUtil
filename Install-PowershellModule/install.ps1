#Requires -Version 2.0

[CmdletBinding()]
Param
(
    [Parameter(
        Position = 0,
        Mandatory = 0)]

    [string]
    $path = $(Split-Path $PSCommandPath -Parent),

    [Parameter(
        Position = 1,
        Mandatory = 0)]

    [string]
    $modulepath = ($env:PSModulePath -split ";" | where {$_ -like ("{0}*" -f [environment]::GetFolderPath("MyDocuments"))})
)

Function Get-OperatingSystemVersion
{
    [System.Environment]::OSVersion.Version
}

Function Test-ModulePath
{

    [CmdletBinding()]
    param
    (
        [Parameter(
            Position = 0,
            Mandatory = 1)]
        [string]
        $modulepath        
    )
 
    Write-Verbose "Checking Module Home."
    if ((Get-OperatingSystemVersion) -ge 6.1)
    {
        Write-Verbose "Your operating system is later then Windows 7 / Windows Server 2008 R2. Continue evaluation."
        return Test-Path -Path $modulepath
    }
}

Function New-ModulePath{

    [CmdletBinding()]
    param
    (
        [Parameter(
            Position = 0,
            Mandatory = 1)]
        [string]
        $modulepath
    )

    if ((Get-OperatingSystemVersion) -ge 6.1)
    {         
        Write-Verbose "Creating Module Home at $modulepath"
        New-Item -Path $modulepath -ItemType directory > $null
        Write-Verbose "$modulepath already exist. Escape from creating module Directory."
    }
}

Function Get-ModuleName{

    [CmdletBinding()]
    param
    (
        [Parameter(
            Position = 0,
            Mandatory = 1)]
        [string]
        $path
    )

    if (Test-Path $path)
    {
        $moduleName = ((Get-ChildItem $path | where {$_.Extension -eq ".psm1"})).BaseName
        return $moduleName
    }
}


Function Copy-Module
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory,
            position = 0)]
        [validateScript({Test-Path $_})]
        [string]
        $path,

        [parameter(
            mandatory,
            position = 1)]
        [validateScript({(Get-Item $_).PSIsContainer -eq $true})]
        [string]
        $destination
    )

    if(Test-Path $path)
    {
        $rootpath = Get-Item $path
        
        Get-ChildItem -Path $path `
        | %{

            # Define target directory path for each directory
            if ($_.Directory.Name -ne $rootpath.Name)
            {
                $script:droot = Join-Path $destination $rootpath.Name
                $script:ddirectory = Join-Path $droot $_.Directory.Name
            }
            else
            {
                $script:ddirectory = Join-Path $destination $_.Directory.Name
            }

            # Check target directory path is already exist or not
            if(-not(Test-Path $ddirectory))
            {
                Write-Verbose "Creating $ddirectory"
                $script:ddirectorypath = New-Item -Path $ddirectory -ItemType Directory -Force
            }
            else
            {
                $script:ddirectorypath = Get-Item -Path $ddirectory
            }

            # Copy Items to target directory
            try
            {
                $script:dpath = Join-Path $ddirectorypath $_.Name

                Write-Host ("Copying '{0}' to {1}" -f $_.FullName, $dpath) -ForegroundColor Cyan
                Copy-Item -Path $_.FullName -Destination $ddirectorypath -Force -Recurse -ErrorAction Stop
            }
            catch
            {
                Write-Error $_
            }
        }

        # return copied destination path
        return $droot
    }
    else
    {
        throw "{0} not found exception!" -f $path
    }
}



Write-Host "Starting check Module path and Copy PowerShell Scripts job." -ForegroundColor Green

Write-Host "Checking is Module Path exist not not." -ForegroundColor Green
if(-not(Test-ModulePath -modulepath $modulepath))
{
    Write-Warning "$modulepath not found. creating module path."
    New-ModulePath -modulepath $modulepath
}

$moduleName = Get-ModuleName -path $path
if ($moduleName)
{
    Write-Host ("Copying module '{0}' to Module path '{1}'." -f $moduleName, "$modulepath") -ForegroundColor Green
}
else
{
    Write-Host ("Copying scripts in '{0}' to Module path '{1}'." -f $path , "$modulepath") -ForegroundColor Green
}
$destinationtfolder = Copy-Module -path $path -destination $modulepath

Write-Host "Installation finished. Scripts copied to PowerShell Module path $destinationtfolder" -ForegroundColor Green

#Requires -Version 2.0

[CmdletBinding()]
Param(
    [Parameter(
        Position = 0,
        Mandatory = 0,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName)]

    [string]
    $path = $(Split-Path $PSCommandPath -Parent)
)

Function Get-OperatingSystemVersion{
    (Get-WmiObject -Class Win32_OperatingSystem).Version
}

Function Test-ModulePath{

    [CmdletBinding()]
    param(
    )

    $script:modulepath = "$env:userProfile\documents\WindowsPowerShell\Modules"
 
    Write-Verbose "Checking Module Home."
    if ([int](Get-OperatingSystemVersion).substring(0,1) -ge 6) 
    { 
        if(-not(Test-Path -path $modulepath))
        {
            Write-Verbose "Creating Module Home at $modulepath"
            New-Item -Path $modulepath -itemtype directory > $null
        }
        else
        {
            Write-Verbose "$modulepath already exist. Escape from creating module Directory."
        }
    }

    return $modulepath
}

Function Copy-Module{
    
    [CmdletBinding()]
    param(
        [parameter(
            mandatory,
            position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [validateScript({Test-Path $path})]
        [string]
        $path,

        [parameter(
            mandatory,
            position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [validateScript({(Get-Item $_).PSIsContainer -eq $true})]
        [string]
        $destination
    )

    if(Test-Path $path)
    {
        $rootpath = Get-Item $path
        
        Get-ChildItem -Path $path -File -Recurse | %{

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
                if (-not($_.PSIsContainer))
                {
                    $script:dpath = Join-Path $ddirectorypath $_.Name

                    Write-Verbose "Copying $($_.name) to $dpath"
                    Copy-Item -Path $_.FullName -Destination $ddirectorypath -Force -Recurse -ErrorAction Stop
                }
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
$modulepath = Test-ModulePath

Write-Host "Copying Scripts to Module path." -ForegroundColor Green
$destinationtfolder = Copy-Module -path $path -destination $modulepath

Write-Host "Installation finished. Scripts copied to PowerShell Module path $destinationtfolder" -ForegroundColor Green

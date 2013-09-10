#Requires -Version 3.0

function Filelock{

    param (
        [parameter(
            position = 0,
            mandatory
        )]
        [System.IO.FileInfo]
        $Path
    )
    
    try
    {
        # initialise variables
        $script:filelocked = $false

        # attempt to open file and detect file lock
        $script:fileInfo = New-Object System.IO.FileInfo $Path
        $script:fileStream = $fileInfo.Open([System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

        # close stream if not lock
        if ($fileStream)
        {
            $fileStream.Close()
        }
    }
    catch
    {
        # catch fileStream had falied
        $filelocked = $true
        
    }
    finally
    {
        # return result
        [PSCustomObject]@{
            path = $Path
            filelocked = $filelocked
        }
    }
}



function Test-FileLock {

    param (
        [parameter(
            position = 0,
            mandatory
        )]
        [string]
        $Path
    )

    try
    {    
        if(Test-Path $Path)
        {
            if ((Get-Item -path $path) -is [System.IO.FileInfo])
            {
                return (filelock -Path $Path).filelocked
            }
            elseif((Get-Item $Path) -is [System.IO.DirectoryInfo])
            {
                Write-Verbose "[$Path] detect as $((Get-Item -path $Path).GetType().FullName). Skip cehck."
            }
        }
        else
        {
            Write-Error "[$Path] could not find. 
            + CategoryInfo          : ObjectNotFound: ($Path), ItemNotFoundException
            + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.GetItemCommand"
        }
    }
    catch
    {
        Write-Error $_
    }
}



function Get-FileLock
{

    param (
        [parameter(
            position = 0,
            mandatory
        )]
        [string]
        $Path
    )

    try
    {
        if(Test-Path $Path)
        {
            if ((Get-Item -path $path) -is [System.IO.FileInfo])
            {
                return filelock -Path $Path
            }
            elseif((Get-Item $Path) -is [System.IO.DirectoryInfo])
            {
                Write-Verbose "[$Path] detect as $((Get-Item -path $Path).GetType().FullName). Skip check."
            }
        }
        else
        {
            Write-Error "[$Path] could not find. 
            + CategoryInfo          : ObjectNotFound: ($Path), ItemNotFoundException
            + FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.GetItemCommand"
        }
    }
    catch
    {
        Write-Error $_
    }
    
}


Export-ModuleMember `
    -Function `
        Test-FileLock,
        Get-FileLock

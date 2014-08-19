#Requires -Version 3.0

#-- SymbolicLink Functions --#

<#
.SYNOPSIS 
This function will detect only SymbolicLink items.

.DESCRIPTION
PowerShell SymbolicLink function. Alternative to mklink Symbolic Link.
This function detect where input file fullpath item is file/directory SymbolicLink, then only Ennumerate if it is SymbolicLink.

.NOTES
Author: guitarrapc
Created: 12/Aug/2014

.EXAMPLE
ls d:\ | Get-SymbolicLink
--------------------------------------------
Pipeline Input to detect SymbolicLink items.

.EXAMPLE
Get-SymbolicLink (ls d:\).FullName
--------------------------------------------
Parameter Input to detect SymbolicLink items.
#>
function Get-SymbolicLink
{
    [cmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 1,
            Position  = 0,
            ValueFromPipeline =1,
            ValueFromPipelineByPropertyName = 1)]
        [Alias('FullName')]
        [String[]]
        $Path
    )
    
    process
    {
        try
        {
            $Path `
            | %{
                if ($file = IsFile -Path $_)
                {
                    if (IsFileReparsePoint -Path $file.FullName)
                    {
                        return $file
                    }
                }
                elseif ($directory = IsDirectory -Path $_)
                {
                    if (IsDirectoryReparsePoint -Path $directory.FullName)
                    {
                        return $directory
                    }
                }
            }
        }
        catch
        {
            throw $_
        }
    }    

    begin
    {
        $script:ErrorActionPreference = 'Stop'

        function IsFile ([string]$Path)
        {
            if ([System.IO.File]::Exists($Path))
            {
                Write-Verbose ("Input object : '{0}' detected as File." -f $Path)
                return [System.IO.FileInfo]($Path)
            }
        }

        function IsDirectory ([string]$Path)
        {
            if ([System.IO.Directory]::Exists($Path))
            {
                Write-Verbose ("Input object : '{0}' detected as Directory." -f $Path)
                return [System.IO.DirectoryInfo] ($Path)
            }
        }

        function IsFileReparsePoint ([System.IO.FileInfo]$Path)
        {
            Write-Verbose ('File attribute detected as ReparsePoint')
            $fileAttributes = [System.IO.FileAttributes]::Archive, [System.IO.FileAttributes]::ReparsePoint -join ', '
            $attribute = [System.IO.File]::GetAttributes($Path)
            $result = $attribute -eq $fileAttributes
            if ($result)
            {
                Write-Verbose ('Attribute detected as ReparsePoint. : {0}' -f $attribute)
                return $result
            }
            else
            {
                Write-Verbose ('Attribute detected as NOT ReparsePoint. : {0}' -f $attribute)
                return $result
            }
        }

        function IsDirectoryReparsePoint ([System.IO.DirectoryInfo]$Path)
        {
            $directoryAttributes = [System.IO.FileAttributes]::Directory, [System.IO.FileAttributes]::ReparsePoint -join ', '
            $result = $Path.Attributes -eq $directoryAttributes
            if ($result)
            {
                Write-Verbose ('Attribute detected as ReparsePoint. : {0}' -f $Path.Attributes)
                return $result
            }
            else
            {
                Write-Verbose ('Attribute detected as NOT ReparsePoint. : {0}' -f $Path.Attributes)
                return $result
            }
        }
    }
}
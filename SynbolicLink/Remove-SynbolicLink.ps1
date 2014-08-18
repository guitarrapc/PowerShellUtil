#Requires -Version 3.0

#-- SymbolicLink Functions --#

<#
.SYNOPSIS 
This function will Remove only SymbolicLink items.

.DESCRIPTION
PowerShell SymbolicLink function. Alternative to mklink Symbolic Link.
This function detect where input file fullpath item is file/directory SymbolicLink, then only remove if it is SymbolicLink.
You don't need to care about input Path is FileInfo or DirectoryInfo.

.NOTES
Author: guitarrapc
Created: 12/Aug/2014

.EXAMPLE
ls d:\ | Remove-SymbolicLink
--------------------------------------------
Pipeline Input to detect SymbolicLink items.

.EXAMPLE
Remove-SymbolicLink (ls d:\).FullName
--------------------------------------------
Parameter Input to detect SymbolicLink items.
#>
function Remove-SymbolicLink
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
                    if (IsFileReparsePoint -Path $file)
                    {
                        RemoveFileReparsePoint -Path $file
                    }
                }
                elseif ($directory = IsDirectory -Path $_)
                {
                    if (IsDirectoryReparsePoint -Path $directory)
                    {
                        RemoveDirectoryReparsePoint -Path $directory
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
            $attribute = [System.IO.File]::GetAttributes($Path.fullname)
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

        function RemoveFileReparsePoint ([System.IO.FileInfo]$Path)
        {
            [System.IO.File]::Delete($Path.FullName)
        }
        
        function RemoveDirectoryReparsePoint ([System.IO.DirectoryInfo]$Path)
        {
            [System.IO.Directory]::Delete($Path.FullName)
        }
    }
}
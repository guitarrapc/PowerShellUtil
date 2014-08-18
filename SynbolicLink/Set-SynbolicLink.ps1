#Requires -Version 3.0

<#
.SYNOPSIS 
This function will Set SymbolicLink items for desired Path.

.DESCRIPTION
PowerShell SymbolicLink function. Alternative to mklink Symbolic Link.
This function will create Symbolic Link for input file fullpath.
Also it works as like LINQ Zip method for different number items was passed for each -Path and -SymbolicPath.
As Zip use minimal number item, this function also follow it.

.NOTES
Author: guitarrapc
Created: 12/Aug/2014

.EXAMPLE
ls d:\ `
| select -Last 2 `
| %{
    @{
        Path = $_.FullName
        SymbolicPath = Join-Path "d:\zzzzz" $_.Name
    }
} `
| Set-SymbolicLink -Verbose
--------------------------------------------
Pipeline Input to create SymbolicLink items. This will make symbolic in d:\zzzz with samename of input Path name.
This means you can easily create Symbolic for different Path.

.EXAMPLE
Set-SymbolicLink -Path (ls d:\ | select -Last 2).FullName -SymbolicPath d:\hoge1, d:\hoge2, d:\hoge3 -Verbose
--------------------------------------------
Parameter Input. This will create Symbolic Link for -Path input 2 items, with -SymbolicPath input d:\hoge1 and d:\hoge2.
As number input was less with -Path, d:\hoge3 will be ignore.

#>
function Set-SymbolicLink
{
    [cmdletBinding(DefaultParameterSetName = "ForceFile")]
    param
    (
        [parameter(
            Mandatory = 1,
            Position  = 0,
            ValueFromPipeline =1,
            ValueFromPipelineByPropertyName = 1)]
        [Alias('TargetPath')]
        [Alias('FullName')]
        [String[]]
        $Path,

        [parameter(
            Mandatory = 1,
            Position  = 1,
            ValueFromPipelineByPropertyName = 1)]
        [String[]]
        $SymbolicPath,

        [parameter(
            Mandatory = 0,
            Position  = 2,
            ValueFromPipelineByPropertyName = 1,
            ParameterSetName = "ForceFile")]
        [bool]
        $ForceFile = $false,

        [parameter(
            Mandatory = 0,
            Position  = 2,
            ValueFromPipelineByPropertyName = 1,
            ParameterSetName = "ForceDirectory")]
        [bool]
        $ForceDirectory = $false
    )
    
    process
    {
        # Work as like LINQ Zip() method
        $zip = NewZipPairs -key $Path -value $SymbolicPath -Prefix $prefix
        foreach ($x in $zip.GetEnumerator())
        {
            # reverse original key
            $targetPath = ($x.Key -split "$($prefix * ($i + 1))" | select -Last 1)
            $SymbolicNewPath = $x.value

            if ($ForceFile -eq $true)
            {
                [SymbolicLink.Utils]::CreateSymLink($SymbolicNewPath, $Path, $false)
            }
            elseif ($ForceDirectory -eq $true)
            {
                [SymbolicLink.Utils]::CreateSymLink($SymbolicNewPath, $Path, $true)
            }
            elseif ($file = IsFile -Path $targetPath)
            {
                # Check File Type
                if (IsFileAttribute -Path $file)
                {
                    Write-Verbose ("symbolicPath : '{0}',  target : '{1}', isDirectory : '{2}'" -f $SymbolicNewPath, $file.fullname, $false)
                    [SymbolicLink.Utils]::CreateSymLink($SymbolicNewPath, $file.fullname, $false)
                }
            }
            elseif ($directory = IsDirectory -Path $targetPath)
            {
                # Check Directory Type
                if (IsDirectoryAttribute -Path $directory)
                {
                    Write-Verbose ("symbolicPath : '{0}',  target : '{1}', isDirectory : '{2}'" -f $SymbolicNewPath, $directory.fullname, $true)
                    # [SymbolicLink.Utils]::CreateSymLink()
                    [SymbolicLink.Utils]::CreateSymLink($SymbolicNewPath, $directory.fullname, $true)
                }
            } 
            
            # increment prefix length
            $i++
        }
    }    

    begin
    {
        $script:ErrorActionPreference = 'Stop'
        $prefix = "_"
        $i = 0 # Initialize prefix Length

        try
        {
            Add-Type -Namespace SymbolicLink -Name Utils -MemberDefinition @"
internal static class Win32
{
    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.I1)]
    public static extern bool CreateSymbolicLink(string lpSymlinkFileName, string lpTargetFileName, SymLinkFlag dwFlags);
 
    internal enum SymLinkFlag
    {
        File = 0,
        Directory = 1
    }
}
public static void CreateSymLink(string name, string target, bool isDirectory = false)
{
    if (!Win32.CreateSymbolicLink(name, target, isDirectory ? Win32.SymLinkFlag.Directory : Win32.SymLinkFlag.File))
    {
        throw new System.ComponentModel.Win32Exception();
    }
}
"@
        }
        catch
        {
            # catch Exception and ignore it
        }

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

        function IsFileAttribute ([System.IO.FileInfo]$Path)
        {
            $fileAttributes = [System.IO.FileAttributes]::Archive
            $attribute = [System.IO.File]::GetAttributes($Path.fullname)
            $result = $attribute -eq $fileAttributes
            if ($result)
            {
                Write-Verbose ('Attribute detected as File Archive. : {0}' -f $attribute)
                return $result
            }
            else
            {
                Write-Verbose ('Attribute detected as NOT File archive. : {0}' -f $attribute)
                return $result
            }
        }

        function IsDirectoryAttribute ([System.IO.DirectoryInfo]$Path)
        {
            $directoryAttributes = [System.IO.FileAttributes]::Directory
            $result = $Path.Attributes -eq $directoryAttributes
            if ($result)
            {
                Write-Verbose ('Attribute detected as Directory. : {0}' -f $Path.Attributes)
                return $result
            }
            else
            {
                Write-Verbose ('Attribute detected as NOT Directory. : {0}' -f $Path.Attributes)
                return $result
            }
        }

        function NewZipPairs
        {
            [CmdletBinding()]
            param
            (
                [parameter(
                    Mandatory = 1,
                    Position = 0,
                    ValueFromPipelineByPropertyName = 1)]
                [string[]]
                $key,

                [parameter(
                    Mandatory = 1,
                    Position = 1,
                    ValueFromPipelineByPropertyName = 1)]
                [string[]]
                $value,

                [parameter(
                    Mandatory = 0,
                    Position = 2)]
                [string]
                $Prefix = "_"
            )

            begin
            {
                function ToArrayEx ([string[]]$InputStringArray)
                {
                    $array = @()
                    $array += $InputStringArray | %{$_}
                    $array
                }
            }

            process
            {
                # ToArray
                [string[]]$keys = ToArrayEx -InputStringArray $key
                [string[]]$values = ToArrayEx -InputStringArray $value

                # Element Count Check
                $keyElementsCount = ($keys | measure).count
                $valueElementsCount = ($values | measure).count
                if ($valueElementsCount -eq 0)
                {
                    # TagValue auto fill with "*" when Value is empty
                    $values = 1..$keyElementsCount | %{"*"}
                }

                # Get shorter list
                $length = if ($keyElementsCount -le $valueElementsCount)
                {
                    $keyElementsCount
                }
                else
                {
                    $valueElementsCount
                }

                # Make Element Pair
                $i = 0
                $dictionary = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'
                do
                {
                    # make new key to avoid duplicate entry
                    $key = "$($prefix * ($i + 1))" + $($keys[$i])
                    $dictionary.Add($key,$values[$i])
                    $i++
                }
                while ($i -lt $length)
            }

            end
            {
                return $dictionary
            }
        }
    }
}

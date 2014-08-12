function Copy-StrictedFilterFileWithDirectoryStructure
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 1,
            position  = 0,
            ValueFromPipeline = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $Path,
 
        [parameter(
            mandatory = 1,
            position  = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $Destination,
 
        [parameter(
            mandatory = 1,
            position  = 2,
            ValueFromPipelineByPropertyName = 1)]
        [string[]]
        $Targets,
 
        [parameter(
            mandatory = 0,
            position  = 3,
            ValueFromPipelineByPropertyName = 1)]
        [string[]]
        $Excludes
    )
 
    begin
    {
        $list = New-Object 'System.Collections.Generic.List[String]'
    }
 
    process
    {
        Foreach ($target in $Targets)
        {
            # Copy "All Directory Structure" and "File" which Extension type is $ex
            Copy-Item -Path $Path -Destination $Destination -Force -Recurse -Filter $target
        }
    }
 
    end
    {
        # Remove -Exclude Item
        Foreach ($exclude in $Excludes)
        {
            Get-ChildItem -Path $Destination -Recurse -File | where Name -like $exclude | Remove-Item
        }
 
        # search Folder which include file
        $allFolder = Get-ChildItem $Destination -Recurse -Directory
        $containsFile = $allFolder | where {$_.GetFiles()}
        $containsFile.FullName `
        | %{
            $fileContains = $_
            $result = $allFolder.FullName `
            | where {$_ -notin $list} `
            | where {
                $shortPath = $_
                $fileContains -like "$shortPath*"
            }
            $result | %{$list.Add($_)}
        }
        $folderToKeep = $list | sort -Unique
 
        # Remove All Empty (none file exist) folders
        Get-ChildItem -Path $Destination -Recurse -Directory | where fullName -notin $folderToKeep | Remove-Item -Recurse
    }
}

<#
Copy-StrictedFilterFileWithDirectoryStructure -Path c:\valentia -Destination C:\hoge -Targets *.bat, *.md -Exclude Readme_J.md
 
# Sample
Copy-StrictedFilterFileWithDirectoryStructure -Path C:\valentia -Destination C:\hoge -Targets .bat, .md
 
# Sample : -Exlude item will not exit in copied folder
Copy-StrictedFilterFileWithDirectoryStructure -Path C:\valentia -Destination C:\hoge -Targets *.bat, *.md -Excludes Readme*.md
#>
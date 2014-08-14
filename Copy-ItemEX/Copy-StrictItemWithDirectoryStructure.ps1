function Copy-StrictItemWithDirectoryStructure
{
    [cmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 1,
            Position  = 0,
            ValueFromPipeline = 1,
            ValueFromPipelineByPropertyName =1)]
        $inputPath,

        [parameter(
            Mandatory = 1,
            Position  = 1,
            ValueFromPipelineByPropertyName =1)]
        [string[]]
        $Destination,

        [parameter(
            Mandatory = 1,
            Position  = 1,
            ValueFromPipelineByPropertyName =1)]
        [string]
        $InputRoot
    )
    begin
    {
        $root = $InputRoot.Replace("\", "\\")
    }

    process
    {
        $inputPath `
        | %{
            $directoryName = Join-Path $Destination ($_.DirectoryName -split $root |select -Last 1)
        [PSCustomObject]@{
            Path = $_.FullName
            DirectoryName = $directoryName
            Destination = Join-Path $directoryName $_.Name
            }} `
        | %{
            New-Item $_.DirectoryName -ItemType Directory -Force
            Copy-Item -Path $_.Path -Destination $_.Destination -Force
        }
    }
}

# Usage : Copy item from c:\valentia to c:\hoge
# $hoge = ls D:\valentia -Recurse | where {$_.Extension -eq ".ps1"}
# Copy-StrictItemWithDirectoryStructure -inputPath $hoge -Destination D:\hoge -InputRoot D:\valentia

function New-ZipCompression{

    [CmdletBinding()]
    param(
        [parameter(
            mandatory,
            position = 0,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $source,

        [parameter(
            mandatory,
            position = 1,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $destination,

        [parameter(
            mandatory = 0,
            position = 2)]
        [switch]
        $quiet
    )

    $zipExtension = ".zip"

    try
    {
        Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    }
    catch
    {
    }

    if (-not($destination.EndsWith($zipExtension)))
    {
        throw ("destination parameter value [{0}] not end with extension {1}" -f $destination, $zipExtension)
    }
        
    try
    {
        $destzip = [System.IO.Compression.Zipfile]::Open($destination,"Update")
        $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
        $files = Get-ChildItem -Path $source -Recurse | where {-not($_.PSISContiner)}

        foreach ($file in $files)
        {
            $file2 = $file.name

            if ($quiet)
            {
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($destzip,$file.fullname,$file2,$compressionLevel) > $null
                $?
            }
            else
            {
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($destzip,$file.fullname,$file2,$compressionLevel)
            }
        }

        $destzip.Dispose()
    }
    catch
    {
        Write-Error $_
    }
}




function New-ZipExtract{

    [CmdletBinding()]
    param(
        [parameter(
            mandatory,
            position = 0,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $source,

        [parameter(
            mandatory,
            position = 1,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $destination,

        [parameter(
            mandatory = 0,
            position = 2)]
        [switch]
        $quiet
    )

    $zipExtension = ".zip"

    try
    {
        Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    }
    catch
    {
    }

    if (-not($source.EndsWith($zipExtension)))
    {
        throw ("source parameter value [{0}] not end with extension {1}" -f $source, $zipExtension)
    }
        
    try
    {
        $sourcezip = [System.IO.Compression.Zipfile]::Open($source,"Update")
        $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

        if ($quiet)
        {
            [System.IO.Compression.ZipFileExtensions]::ExtractToDirectory($sourcezip,$destination) > $null
            $?
        }
        else
        {
            [System.IO.Compression.ZipFileExtensions]::ExtractToDirectory($sourcezip,$destination)
        }

        $sourcezip.Dispose()
    }
    catch
    {
        Write-Error $_
    }
}



Export-ModuleMember `
    -Function * `
    -Cmdlet * `
    -Variable *


# Compres Sample
# New-ZipCompression -source D:\test -destination d:\hoge.zip
# New-ZipCompression -source D:\test -destination d:\hoge.zip -quiet

# Extract Sample
# New-ZipExtract -source d:\hoge.zip -destination d:\hogehoge
# New-ZipExtract -source d:\hoge.zip -destination d:\hogehoge -quiet

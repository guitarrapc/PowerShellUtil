function New-ZipCompress{

    [CmdletBinding(DefaultParameterSetName="safe")]
    param(
        [parameter(
            mandatory,
            position = 0,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $source,

        [parameter(
            mandatory = 0,
            position = 1,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $destination,

        [parameter(
            mandatory = 0,
            position = 2)]
        [switch]
        $quiet,

        [parameter(
            mandatory = 0,
            position = 3,
            ParameterSetName="safe")]
        [switch]
        $safe,

        [parameter(
            mandatory = 0,
            position = 3,
            ParameterSetName="force")]
        [switch]
        $force
    )

    try
    {
        Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    }
    catch
    {
    }


    # check source is "file/directory" or "contains PSISContainer"
    Write-Verbose "Detected as source not using * without extension"
    $file = Get-Item -Path $source

    # change source to parent folder
    if ($file.PSISContainer -and ($file.count -gt 1) -and ($source[-1] -eq "*"))
    {
        Write-Verbose "Detected as source using * without extension"
        $oldsource = $source
        $f = Get-Item -Path $source | select -First 1
        $source = Split-Path -Path $f -Parent
        $file = Get-Item -Path $source
        Write-Verbose ("changed source {0} to parent folder {1}." -f $oldsource, $source)
    }

    # set zip extension
    $zipExtension = ".zip"

    # set desktop as destination path if it null
    if ([string]::IsNullOrWhiteSpace($destination))
    {
        $desktop = [System.Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)

        if ($file.PSISContainer -and ($file.count -eq 1))
        {
            Write-Verbose "Detected as Directory"

            if ($file.FullName -eq $file.Root)
            {
                $filename = $file.PSDrive.Name
            }
            else
            {
                # remove \ or / on last letter of source
                $fullpath = Join-Path (Split-Path -Path $file -Parent) (Split-Path -Path $file -Leaf)
                $filename = [System.IO.Path]::GetFileName($fullpath)
            }

            Write-Verbose ("Desktop : {0}" -f $desktop)
            Write-Verbose ("GetFileName : {0}" -f $filename)
            Write-Verbose ("zipExtension : {0}" -f $zipExtension)

            $destination = Join-Path $desktop ($filename + $zipExtension)
        }
        elseif ($file.PSISContainer -and ($file.count -gt 1) -and ($source[-1] -eq "*"))
        {
            Write-Verbose "Detected as source which use * without extension"
            Write-Verbose "create zip from parent directory when last letter of source was wildcard *"
            
            $filename = ([System.IO.Path]::GetFileNameWithoutExtension($file.FullName))

            Write-Verbose ("Desktop : {0}" -f $desktop)
            Write-Verbose ("GetFileName : {0}" -f $filename)
            Write-Verbose ("zipExtension : {0}" -f $zipExtension)

            $destination = Join-Path $desktop ($filename + $zipExtension)
        }
        else
        {
            Write-Verbose "Detected as File"

            # use first file name as zip name
            $filename = ([System.IO.Path]::GetFileNameWithoutExtension(($file | select -First 1 -ExpandProperty fullname)))

            Write-Verbose ("Desktop : {0}" -f $desktop)
            Write-Verbose ("GetFileName : {0}" -f ([System.IO.Path]::GetFileNameWithoutExtension(($file | select -First 1 -ExpandProperty fullname))))
            Write-Verbose ("zipExtension : {0}" -f $zipExtension)

            $destination = Join-Path $desktop ($filename + $zipExtension)
        }   
    }

    # check destination is input as .zip
    if (-not($destination.EndsWith($zipExtension)))
    {
        throw ("destination parameter value [{0}] not end with extension {1}" -f $destination, $zipExtension)
    }

    # check destination is exist or not
    if (Test-Path $destination)
    {
        # safe output zip file to new destination path, avoiding destination zip name conflict.
        if ($safe)
        {
            # check destination is already exist, CreateFromDirectory will fail with same name of destination file.
            # show warning for same destination exist.
            Write-Verbose ("Detected destination name {0} is already exist." -f $destination)

            $olddestination = $destination

            # get current destination information
            $destinationRoot = [System.IO.Path]::GetDirectoryName($destination)
            $destinationfile = [System.IO.Path]::GetFileNameWithoutExtension($destination)
            $destinationExtension = [System.IO.Path]::GetExtension($destination)

            # renew destination name with (2)...(x) until no more same name catch.
            $count = 2
            $destination = Join-Path $destinationRoot ($destinationfile + "(" + $count + ")" + $destinationExtension)
            while (Test-Path $destination)
            {
                ++$count
                $destination = Join-Path $destinationRoot ($destinationfile + "(" + $count + ")" + $destinationExtension)
            }

            # show warning as destination name had been changed due to escape error.
            Write-Warning ("Safe old deistination {0} change to new name {1}" -f $olddestination, $destination)
        }
        else
        {
            if($force)
            {
                Write-Warning ("force replacing old zip file {0}" -f $destination)
                Remove-Item -Path $destination -Force
            }
            else
            {
                Remove-Item -Path $destination -Confirm
            }

            if (Test-Path $destination)
            {
                Write-Warning "Cancelled removing item. Quit cmdlet execution."
                return
            }
        }
    }
    else
    {
        # create parent folder
        $parentpath = Split-Path $destination -Parent
        if (-not(Test-Path $parentpath))
        {
            New-Item -Path $parentpath -ItemType Directory -Force
        }
    }


    # compressionLevel
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

    # check source is Directory or file
    Write-Verbose ("file.Attributes = {0}" -f $file.Attributes)
    Write-Verbose ("file.count = {0}" -f $file.count)

    # execute compression
    if ($file.PSISContainer -and ($file.count -eq 1))
    {
        try # create zip from directory
        {
            # include BaseDirectory
            $includeBaseDirectory = $true

            Write-Verbose ("destination = {0}" -f $destination)

            Write-Verbose ("file.fullname = {0}" -f $file.FullName)
            Write-Verbose ("compressionLevel = {0}" -f $compressionLevel)
            Write-Verbose ("includeBaseDirectory = {0}" -f $includeBaseDirectory)

            if ($quiet)
            {
                Write-Verbose ("zipping up folder {0} to {1}" -f $file.FullName,$destination)
                [System.IO.Compression.ZipFile]::CreateFromDirectory($file.fullname,$destination,$compressionLevel,$includeBaseDirectory) > $null
                $?
            }
            else
            {
                Write-Verbose ("zipping up folder {0} to {1}" -f $file.FullName,$destination)
                [System.IO.Compression.ZipFile]::CreateFromDirectory($file.fullname,$destination,$compressionLevel,$includeBaseDirectory)
                Get-Item $destination
            }
        }
        catch
        {
            Write-Error $_
            $?
        }
    }
    elseif ($file.PSISContainer -and ($file.count -gt 1) -and ($source[-1] -eq "*"))
    {
        try # create zip from directory when last letter of source was wildcard *
        {
            # include BaseDirectory
            $includeBaseDirectory = $true

            Write-Verbose ("destination = {0}" -f $destination)

            Write-Verbose ("file.fullname = {0}" -f $file.FullName)
            Write-Verbose ("compressionLevel = {0}" -f $compressionLevel)
            Write-Verbose ("includeBaseDirectory = {0}" -f $includeBaseDirectory)

            if ($quiet)
            {
                Write-Verbose ("zipping up folder {0} to {1}" -f $file.FullName,$destination)
                [System.IO.Compression.ZipFile]::CreateFromDirectory($file.fullname,$destination,$compressionLevel,$includeBaseDirectory) > $null
                $?
            }
            else
            {
                Write-Verbose ("zipping up folder {0} to {1}" -f $file.FullName,$destination)
                [System.IO.Compression.ZipFile]::CreateFromDirectory($file.fullname,$destination,$compressionLevel,$includeBaseDirectory)
                Get-Item $destination
            }
        }
        catch
        {
            Write-Error $_
            $?
        }
    }
    else
    {
        try # create zip from files
        {
            # create zip to add
            $destzip = [System.IO.Compression.Zipfile]::Open($destination,"Update")

            # get items
            $files = Get-ChildItem -Path $source

            foreach ($file in $files)
            {
                $file2 = $file.name

                Write-Verbose ("destzip = {0}" -f $destzip)
                Write-Verbose ("file.fullname = {0}" -f $file.FullName)
                Write-Verbose ("file2 = {0}" -f $file2)
                Write-Verbose ("compressionLevel = {0}" -f $compressionLevel)

                Write-Verbose ("zipping up files {0} to {1}" -f $file.FullName,$destzip)
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($destzip,$file.fullname,$file2,$compressionLevel) > $null
            }

            # show result
            if ($quiet)
            {
                $?
            }
            else
            {
                Get-Item $destination
            }

        }
        catch
        {
            Write-Error $_
            $?
        }
        finally
        {
            # dispose opened zip
            $destzip.Dispose()
        }
    }
}




function New-ZipExtract{

    [CmdletBinding(DefaultParameterSetName="safe")]
    param(
        [parameter(
            mandatory,
            position = 0,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $source,

        [parameter(
            mandatory = 0,
            position = 1,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $destination,

        [parameter(
            mandatory = 0,
            position = 2)]
        [switch]
        $quiet,

        [parameter(
            mandatory = 0,
            position = 3,
            ParameterSetName="safe")]
        [switch]
        $safe,

        [parameter(
            mandatory = 0,
            position = 3,
            ParameterSetName="force")]
        [switch]
        $force
    )

    try
    {
        Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    }
    catch
    {
    }

    $zipExtension = ".zip"

    # check source is input as .zip
    if (-not($source.EndsWith($zipExtension)))
    {
        throw ("source parameter value [{0}] not end with extension {1}" -f $source, $zipExtension)
    }

    # set desktop as destination path if destination was null
    if ([string]::IsNullOrWhiteSpace($destination))
    {
        $desktop = [System.Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
        $directoryname = [System.IO.Path]::GetFileNameWithoutExtension($source)
        
        Write-Verbose ("Desktop : {0}" -f $desktop)
        Write-Verbose ("GetFileName : {0}" -f $directoryname)

        $destination = Join-Path $desktop $directoryname
    }
        
    # check destination is exist or not
    if (Test-Path $destination)
    {
        # safe output zip file to new destination path, avoiding destination zip name conflict.
        if ($safe)
        {
        # check destination is already exist, CreateFromDirectory will fail with same name of destination file.
            # show warning for same destination exist.
            Write-Verbose ("Detected destination name {0} is already exist. safe trying output to new destination zip name." -f $destination)

            $olddestination = $destination

            # get current destination information
            $destinationRoot = [System.IO.Path]::GetDirectoryName($destination)
            $destinationfile = [System.IO.Path]::GetFileNameWithoutExtension($destination)
            $destinationExtension = [System.IO.Path]::GetExtension($destination)

            # renew destination name with (2)...(x) until no more same name catch.
            $count = 2
            $destination = Join-Path $destinationRoot ($destinationfile + "(" + $count + ")" + $destinationExtension)
            while (Test-Path $destination)
            {
                ++$count
                $destination = Join-Path $destinationRoot ($destinationfile + "(" + $count + ")" + $destinationExtension)
            }

            # show warning as destination name had been changed due to escape error.
            Write-Warning ("Safe old deistination {0} change to new name {1}" -f $olddestination, $destination)
        }
        else
        {
            if($force)
            {
                Write-Warning ("force replacing old zip file {0}" -f $destination)
                Remove-Item -Path $destination -Recurse -Force
            }
            else
            {
                Remove-Item -Path $destination -Recurse -Confirm
            }

            if (Test-Path $destination)
            {
                Write-Warning "Cancelled removing item. Quit cmdlet execution."
                return
            }
        }
    }
    else
    {
        # create parent folder
        $parentpath = Split-Path $destination -Parent
        if (-not(Test-Path $parentpath))
        {
            New-Item -Path $parentpath -ItemType Directory -Force
        }
    }

    try
    {
        # create source zip and complression
        $sourcezip = [System.IO.Compression.Zipfile]::Open($source,"Update")
        $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

        Write-Verbose ("sourcezip = {0}" -f $sourcezip)
        Write-Verbose ("destination = {0}" -f $destination)

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
    finally
    {
        $sourcezip.Dispose()
    }
}



Export-ModuleMember `
    -Function * `
    -Cmdlet * `
    -Variable *


<#
#### Compres Test

$ErrorActionPreference = "stop"

try
{
    1
    New-ZipCompress -source D:\hoge -destination d:\hoge.zip -verbose
    2
    New-ZipCompress -source D:\hoge -verbose
    3
    New-ZipCompress -source D:\hoge -force -verbose
    4
    New-ZipCompress -source D:\hoge -safe -verbose
    5
    New-ZipCompress -source D:\hoge\ -quiet -verbose
    6
    New-ZipCompress -source D:\hoge\* -destination d:\hoge.zip -verbose
    7
    New-ZipCompress -source D:\hoge\* -verbose
    8
    New-ZipCompress -source D:\hoge\* -force -verbose
    9
    New-ZipCompress -source D:\hoge\* -safe -verbose
    10
    New-ZipCompress -source D:\hoge\* -quiet -verbose
    11
    New-ZipCompress -source D:\hoge\*.ps1 -destination d:\hoge.zip -verbose
    12
    New-ZipCompress -source D:\hoge\*.ps1 -verbose
    13
    New-ZipCompress -source D:\hoge\*.ps1 -force -verbose
    14
    New-ZipCompress -source D:\hoge\*.ps1 -safe -verbose
    15
    New-ZipCompress -source D:\hoge\*.ps1 -quiet -verbose
    16
    New-ZipCompress -source R:\ -destination d:\hoge.zip -verbose
    17
    New-ZipCompress -source R:\ -verbose
    18
    New-ZipCompress -source R:\ -force -verbose
    19
    New-ZipCompress -source R:\ -safe -verbose
    20
    New-ZipCompress -source R:\ -quiet -verbose
}
catch
{
    Write-Error $_
}



#### Extract Test

$ErrorActionPreference = "stop"

try
{
    1
    New-ZipExtract -source D:\hoge.zip -destination d:\hogehogehoge -verbose
    2
    New-ZipExtract -source D:\hoge.zip -verbose
    3
    New-ZipExtract -source D:\hoge.zip -force -verbose
    4
    New-ZipExtract -source D:\hoge.zip -safe -verbose
    5
    New-ZipExtract -source D:\hoge.zip -quiet -verbose
}
catch
{
    Write-Error $_
}
#>
function Copy-ItemEX
{
    param
    (
        [parameter(
            Mandatory = 1,
            Position  = 0,
            ValueFromPipeline = 1,
            ValueFromPipelineByPropertyName =1)]
        [alias('PSParentPath')]
        [string]
        $Path,

        [parameter(
            Mandatory = 1,
            Position  = 1,
            ValueFromPipelineByPropertyName =1)]
        [string]
        $Destination,

        [parameter(
            Mandatory = 0,
            Position  = 2,
            ValueFromPipelineByPropertyName =1)]
        [string[]]
        $Targets,

        [parameter(
            Mandatory = 0,
            Position  = 3,
            ValueFromPipelineByPropertyName =1)]
        [string[]]
        $Excludes,

        [parameter(
            Mandatory = 0,
            Position  = 4,
            ValueFromPipelineByPropertyName =1)]
        [Switch]
        $Recurse,

        [parameter(
            Mandatory = 0,
            Position  = 5)]
        [switch]
        $Force,

        [parameter(
            Mandatory = 0,
            Position  = 6)]
        [switch]
        $WhatIf
    )

    process
    {
        # Test Path
        if (-not (Test-Path $Path)){throw 'Path not found Exception!!'}

        # Get Filter Item Path as List<Tuple<string>,<string>,<string>>
        $filterPath = GetTargetsFiles -Path $Path -Targets $Targets -Recurse:$isRecurse -Force:$Force

        # Remove Exclude Item from Filter Item
        $excludePath = GetExcludeFiles -Path $filterPath -Excludes $Excludes

        # Execute Copy, confirmation and WhatIf can be use.
        CopyItemEX  -Path $excludePath -RootPath $Path -Destination $Destination -Force:$isForce -WhatIf:$isWhatIf
    }

    begin
    {
        $isRecurse = $PSBoundParameters.ContainsKey('Recurse')
        $isForce = $PSBoundParameters.ContainsKey('Force')
        $isWhatIf = $PSBoundParameters.ContainsKey('WhatIf')

        function GetTargetsFiles
        {
            [CmdletBinding()]
            param
            (
                [string]
                $Path,

                [string[]]
                $Targets,

                [bool]
                $Recurse,

                [bool]
                $Force
            )

            # fullName, DirectoryName, Name
            $list = New-Object 'System.Collections.Generic.List[Tuple[string,string,string]]'
            $base = Get-ChildItem $Path -Recurse:$Recurse -Force:$Force

            if (($Targets | measure).count -ne 0)
            {
                foreach($target in $Targets)
                {
                    $base `
                    | where Name -like $target `
                    | %{
                        if ($_ -is [System.IO.FileInfo])
                        {
                            $tuple = New-Object 'System.Tuple[[string], [string], [string]]' ($_.FullName, $_.DirectoryName, $_.Name)
                        }
                        elseif ($_ -is [System.IO.DirectoryInfo])
                        {
                            $tuple = New-Object 'System.Tuple[[string], [string], [string]]' ($_.FullName, $_.PSParentPath, $_.Name)
                        }
                        else
                        {
                            throw "Type '{0}' not imprement Exception!!" -f $_.GetType().FullName
                        }
                        $list.Add($tuple)
                    }
                }
            }
            else
            {
                $base `
                | %{
                    if ($_ -is [System.IO.FileInfo])
                    {
                        $tuple = New-Object 'System.Tuple[[string], [string], [string]]' ($_.FullName, $_.DirectoryName, $_.Name)
                    }
                    elseif ($_ -is [System.IO.DirectoryInfo])
                    {
                        $tuple = New-Object 'System.Tuple[[string], [string], [string]]' ($_.FullName, $_.PSParentPath, $_.Name)
                    }
                    else
                    {
                        throw "Type '{0}' not imprement Exception!!" -f $_.GetType().FullName
                    }
                    $list.Add($tuple)
                }
            }
            
            return $list
        }

        function GetExcludeFiles
        {
            param
            (
                [System.Collections.Generic.List[Tuple[string,string,string]]]
                $Path,

                [string[]]
                $Excludes
            )

            if (($Excludes | measure).count -ne 0)
            {
                Foreach ($exclude in $Excludes)
                {
                    # name not like $exclude
                    $Path | where Item3 -notlike $exclude
                }
            }
            else
            {
                $Path
            }

        }

        function CopyItemEX
        {
            [cmdletBinding(
                SupportsShouldProcess = $true,
                ConfirmImpact         = 'High')]
            param
            (
                [System.Collections.Generic.List[Tuple[string,string,string]]]
                $Path,

                [string]
                $RootPath,

                [string]
                $Destination,

                [bool]
                $Force
            )

            begin
            {
                # remove default bound "Force"
                $PSBoundParameters.Remove('Force') > $null
            }

            process
            {
                # convert to regex format
                $root = $RootPath.Replace('Microsoft.PowerShell.Core\FileSystem::','').Replace('\', '\\')

                $Path `
                | %{
                    # create destination DirectoryName
                    $directoryName = Join-Path $Destination ($_.Item2 -split $root | select -Last 1)
                    [PSCustomObject]@{
                        Path = $_.Item1
                        DirectoryName = $directoryName
                        Destination = Join-Path $directoryName $_.Item3
                    }} `
                | where {$Force -or $PSCmdlet.ShouldProcess($_.Path, ('Copy Item to {0}' -f $_.Destination))} `
                | %{
                    Write-Verbose ("Copying '{0}' to '{1}'." -f $_.Path, $_.Destination)
                    New-Item -Path $_.DirectoryName -ItemType Directory -Force > $null
                    Copy-Item -Path $_.Path -Destination $_.Destination -Force
                }
            }
        }
    }
}

# Parameter Input
# Copy-ItemEX -Path D:\valentia -Destination D:\hoge -Targets * -Recurse -Excludes Read* -Verbose            # Verbosing progress
# Copy-ItemEX -Path D:\valentia -Destination D:\hoge -Targets * -Recurse -Excludes Read* -WhatIf             # Copy not execute only WhatIf message show up
# Copy-ItemEX -Path D:\valentia -Destination D:\hoge -Targets * -Recurse -Excludes Read* -Force              # Force ls and cp
# Copy-ItemEX -Path D:\gehogemogehoge -Destination D:\hoge -Targets * -Recurse -Excludes Read* -Verbose      # Exception if Path not found

# Pipeline Input
# 'D:\valentia', "d:\fuga"  | Copy-ItemEX -Destination D:\hoge -Targets * -Recurse -Excludes Read* -Verbose  # Verbosing progress
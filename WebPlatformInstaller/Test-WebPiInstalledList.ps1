function Test-WebPiInstalled
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 1,
            Position  = 1,
            ValueFromPipeline = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string[]]
        $Name
    )

    process
    {
        foreach ($x in $name)
        {
            Write-Verbose ("Filtering for Name : '{0}'" -f $x)
            $result = $all `
            | where Name -like $x

            if (($result | measure).count -ne 0)
            {
                $list.Add($true)
            }
            else
            {
                $list.Add($false)
            }
        }
    }

    begin
    {
        $webpi = "$env:ProgramFiles\Microsoft\Web Platform Installer\WebpiCmd-x64.exe"
        if (!(Test-Path -Path $webpi))
        {
            throw "Web Platform Installer not installed exception!!"
        }

        $all = Get-WebPiInstalledList
        $list = New-Object 'System.Collections.Generic.List[bool]'
    }

    end
    {
        return $list
    }
}


# Test-WebPiInstalled -Name "ARRv3_0"
function Get-WebPiInstalledList
{
    [CmdletBinding()]
    param()

    process
    {
        $result = $all `
        | where {$_} `
        | where {$_.length -gt 25} `
        | where {$_[0] -ne "-"} `
        | where {$_[0] -ne "."} `
        | where {$_  -notlike "ID  *"} `
        | Select -Skip 2 `
        | %{
            $name = ($_ -split " ")[0]
            $description = ($_ -split $name)[1] -replace " ",""
            [PSCustomObject]@{
                Name        = $name
                Description = $description
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

        $all = &$webpi /List /ListOption:Installed
    }
    end
    {
        return $result
    }
}


# Get-WebPiInstalledList | where Name -in "ARRv3_0", "WDeploy"
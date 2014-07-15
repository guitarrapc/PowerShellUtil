function Get-ProductId
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 0,
            Position  = 1,
            ValueFromPipeline = 1,
            ValueFromPipelineByPropertyName =1)]
        [string]
        $path = "registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    begin
    {
        if (!(Test-Path $path))
        {
            throw "path '{0}' not found Exception!!" -f $_
        }

        $list = New-Object 'System.Collections.Generic.List[PSCustomObject]'
    }

    process
    {
        $reg = Get-ItemProperty -Path $path | where DisplayName
        $reg `
        | %{
            $obj = [PSCustomObject]@{
                DisplayName    = $_.DisplayName
                DisplayVersion = $_.DisplayVersion
                Publisher      = $_.Publisher
                InstallDate    = [DateTime]::ParseExact($_.InstallDate,"yyyyMMdd",$null)
                ProductId      = $_.PSChildName | %{$_ -replace "{" -replace "}"}
            }
            $list.Add($obj)
        }
    }

    end
    {
        $list
    }
}

Get-ProductId
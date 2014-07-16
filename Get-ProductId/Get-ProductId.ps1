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
        [ValidateNotNullOrEmpty()]
        [string[]]
        $path = "registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    begin
    {
        $list = New-Object 'System.Collections.Generic.List[PSCustomObject]'
    }

    process
    {
        $path `
        | %{
            # validation
            if (!(Test-Path $_))
            {
                throw "path '{0}' not found Exception!!" -f $_
            }

            $reg = Get-ItemProperty -Path $_ | where DisplayName
            $reg `
            | %{
                $obj = [PSCustomObject]@{
                    DisplayName    = $_.DisplayName
                    DisplayVersion = $_.DisplayVersion
                    Publisher      = $_.Publisher
                    InstallDate    = $_ | where {$_.InstallDate} | %{[DateTime]::ParseExact($_.InstallDate,"yyyyMMdd",$null)}
                    ProductId      = $_.PSChildName | %{$_ -replace "{" -replace "}"}
                }
                $list.Add($obj)
            }
        }
    }

    end
    {
        $list | sort DisplayName
    }
}
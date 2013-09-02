function Get-NetTCPConnectionCheck{

    [CmdletBinding()]
    param(

    )
    
    begin
    {
        $result = [ordered]@{}
    }

    process
    {
        $result.date = (Get-Date).ToString("yyyy/MM/dd HH:mm:dd:ss")

        $connection = Get-NetTCPConnection
        $statuslist = @("Listen","Established","CloseWait","LastAck")
        $status = ($connection | group state -NoElement | where Name -in $statuslist).Name

        foreach ($c in $($connection | group State -NoElement))
        {
            $status | %{
                $s = $_
                if (($c | where Name -eq $s).Name -ne $null)
                {
                    $result.Add("$(($c | where Name -eq $s).Name)", ($c | where Name -eq $s).count)
                }
            }
        }
    }

    end
    {
        return [PSCustomObject]$result
    }

}

while (1)
{
    Get-NetTCPConnectionCheck | Out-File -Encoding utf8 -FilePath c:\logs\tcpconnection.log -Append
    sleep 1
}
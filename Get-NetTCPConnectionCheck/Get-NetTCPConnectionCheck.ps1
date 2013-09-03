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
        $status = ($connection | group state -NoElement).Name

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
    Get-NetTCPConnectionCheck
    sleep 1
}
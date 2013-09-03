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
        @("Listen","Established","TimeWait","CloseWait","LastAck","FinWait2") | %{$result.$_ = 0}

        Get-NetTCPConnection | group state -NoElement | where name -in $result.Keys | %{$result.$($_.name) = $_.count}
    }

    end
    {
        return [PSCustomObject]$result
    }

}

# 例のごとく $_ と Export を分岐
&{
    while($true)
    {
        Get-NetTCPConnectionCheck | %{
            $_ | Export-Csv -Path D:\hoge.csv -NoClobber -NoTypeInformation -Append -Encoding UTF8
            $_}
        sleep -Seconds 1
    }
} | Format-Table

# ちなみにこれはダメね
<#
&{
    while($true)
    {
        Get-NetTCPConnectionCheck
        sleep -Seconds 1
    }
} | ConvertTo-Csv -NoTypeInformation | Tee-Object d:\hoge.csv -Append | Format-Table

#>

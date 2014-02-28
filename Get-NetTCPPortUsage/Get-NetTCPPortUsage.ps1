function Get-NetTCPPortUsage
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = $false,
            position  = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Closed", "Listen", "SynSent", "SynReceived", "Established", "FinWait1", "FinWait2", "CloseWait", "Closing", "LastAck", "TimeWait", "DeleteTCB")]
        [string[]]
        $ExceptState,

        [parameter(
            mandatory = $false,
            position  = 1)]
        [ValidateNotNullOrEmpty()]
        [int]
        $ThrottleLimit = 1000,

        [parameter(
            mandatory = $false,
            position  = 2)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Log,

        [parameter(
            mandatory = $false,
            position  = 3)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
        $Encoding = "utf8",

        [parameter(
            mandatory = $false,
            position  = 4)]
        [switch]
        $PassThru
    )
    $portUsage = Get-NetTCPConnection -ThrottleLimit $ThrottleLimit `
    | where State -notin $ExceptState `
    | group state,remoteaddress,remoteport -NoElement `
    | %{[PSCustomObject]@{
        Date           = [string](Get-Date).ToString()
        Count          = [int]($_.Count)
        State          = [string]($_.Name -split ",")[0]
        RemoteAddrress = [ipaddress](($_.Name -split ",")[1].Remove(0,1)).ToString()
        RemotePort     = [int]($_.Name -split ",")[2].Remove(0,1)
        }}
        
    if ($null -ne $log)
    {
        $portUsage | sort RemotePort,RemoteAddress,State | ConvertTo-Json -Compress | Add-Content -Path $Log
    }

    $portUsage | Format-Table -AutoSize


}


<#
while ($true)
{
    $log = "$env:USERPROFILE\desktop\port-_usage.log"
    Get-NetTCPPortUsage -ExceptState Listen -ThrottleLimit 1000 -Log $log -Encoding UTF8 -PassThru
    Write-Host ("waiting for 5 sec") -ForegroundColor Cyan
    sleep -Seconds 5
}
#>
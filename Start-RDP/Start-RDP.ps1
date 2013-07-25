function Start-RDP {

    [CmdletBinding()]
    param(
    [parameter(
        mandatory,
        position = 0)]
    [string]
    $server,

    [parameter(
        mandatory = 0,
        position = 1)]
    [string]
    $RDPPort = 3389
    )

    # Test RemoteDesktop Connection is valid or not
    $TestRemoteDesktop = New-Object System.Net.Sockets.TCPClient -ArgumentList $server,$RDPPort

    # Execute RDP Connection
    if ($TestRemoteDesktop)
    {
        Invoke-Expression "mstsc /v:$server"
    }
    else
    {
        Write-Warning "RemoteDesktop 接続ができませんでした。ネットワーク接続を確認してください。"
    }

}


Start-RDP -server "ServerIp"
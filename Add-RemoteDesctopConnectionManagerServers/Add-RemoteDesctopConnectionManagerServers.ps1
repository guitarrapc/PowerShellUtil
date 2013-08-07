function Add-RemoteDesctopConnectionManagerServers{

    param(
        [string[]]
        $servers
    )

    $result = @()

    foreach($server in $servers)
    {
        $result += "        <server>"
        $result += "            <name>192.168.0.$server</name>"
        $result += "            <displayName>10.0.0.$server</displayName>"
        $result += "            <comment />"
        $result += '            <logonCredentials inherit="FromParent" />'
        $result += '            <connectionSettings inherit="FromParent" />'
        $result += '            <gatewaySettings inherit="FromParent" />'
        $result += '            <remoteDesktop inherit="FromParent" />'
        $result += '            <localResources inherit="FromParent" />'
        $result += '            <securitySettings inherit="FromParent" />'
        $result += '            <displaySettings inherit="FromParent" />'
        $result += "        </server>"
    }

    return $result
}

Add-RemoteDesctopConnectionManagerServers -servers $(10..20)
Add-RemoteDesctopConnectionManagerServers -servers $(30..35)
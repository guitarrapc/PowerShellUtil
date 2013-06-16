# Requires -Version 3.0

function Get-WifiSSID{

    <#
    .SYNOPSIS
        Retrieve Wifi SSID and Connection mode information.

    .DESCRIPTION
        Get-WifiSSID function will check Network Apapter name to get GUID for XML configuration of Wifi.
        You can use Wildcard for adaptor name and cmdlet will get all SSID name belongs to wi-fi name passed.

    .PARAMETER WifiAdaptorName
        String name to specify Wifi Adaptor Name.
        You can use Wildcard to obtain a number of adaptors.
        Not allowed to use regex but can use * for wildcard.

        If you not specified any adaptor name, then defaul name will be use.

    .INPUTS
        system.string

    .OUTPUTS
        system.object
        
    .NOTES
        Author: guitarrapc
        Date:   June 17, 2013

    .EXAMPLE
        C:\PS> Get-WifiSSID

        FileName       : C:\ProgramData\Microsoft\Wlansvc\Profiles\Interfaces\{D43ADEDC-E07D-4B72-98EF-xxxxxx}\{xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx}.xml
        WifiName       : wifiname
        ConnectionMode : auto
        SSIDName       : wifiname
        SSIDHex        : FFFFFFFFFFFFFFFFFFFFFF

    .EXAMPLE
        C:\PS> Get-WifiSSID -WifiAdaptorName "Wi-fi Sample"

        FileName       : C:\ProgramData\Microsoft\Wlansvc\Profiles\Interfaces\{D43ADEDC-E07D-4B72-98EF-xxxxxx}\{xxxxxxx-xxxx-xxxx-xxxx-yyyyyyyyyyy}.xml
        WifiName       : wifiname2
        ConnectionMode : auto
        SSIDName       : wifiname2
        SSIDHex        : FFFFFFFFFFFFFFFFFFFFFC
        
    #>

    [CmdletBinding()]
    param(
        [parameter(
            position = 0,
            mandatory = 0,
            ValueFromPipeLine,
            ValueFromPipeLinebyPropertyName,
            HelpMessage="Specify a Wi-fi Adaptor Name in Network Adaptor list. default : wi-fi*"
        )]
        [string]
        $WifiAdaptorName = "wi-fi*"
    )

    begin
    {
    }

    process
    {

        Write-Verbose "obrain wi-fi GUID where's name contain '$WifiAdaptorName' : Default value is 'wi-fi*' "
        $WifiGUIDs = (Get-NetAdapter -Name $WifiAdaptorName).InterfaceGuid
        
        Write-Verbose "Only run command when GUID was found with AdapterName '$WifiAdaptorName'."
        if (-not($null -eq $WifiGUIDs))
        {
            $InsterfacePath = "C:\ProgramData\Microsoft\Wlansvc\Profiles\Interfaces\"
            foreach ($WifiGUID in $WifiGUIDs)
            {
                $WifiPath = Join-Path $InsterfacePath $WifiGUID

                Write-Verbose "Checking WifiPath is existing or not at '$WifiPath'"
                if (Test-Path $WifiPath)
                {
                    $WifiXmls = Get-ChildItem -Path $WifiPath -Recurse

                    foreach ($wifixml in $WifiXmls)
                    {
                        [xml]$x = Get-Content -Path $wifixml.FullName

                        [PSCustomObject]@{
                        FileName = $WifiXml.FullName
                        WifiName = $x.WLANProfile.Name
                        ConnectionMode = $x.WLANProfile.ConnectionMode
                        SSIDName = $x.WLANProfile.SSIDConfig.SSID.Name
                        SSIDHex = $x.WLANProfile.SSIDConfig.SSID.Hex
                        }
                    }
                }
                else
                {
                    Write-Verbose "Network adaptor was found, but xml was not exist."
                    throw "Wifi GUID Folder not found in $WifiPath!!"
                }
            }
        }
    }

    end
    {
    }

}


Get-WifiSSID
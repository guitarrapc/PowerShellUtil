#Requires -Version 3.0

[CmdletBinding(  
    SupportsShouldProcess = $false,
    ConfirmImpact = "none",
    DefaultParameterSetName = "ExportAsCsv"
)]
param
(
    [Parameter(
    HelpMessage = "Input Path of IIS Log file. Default : C:\inetpub\logs\LogFiles\W3SVC1\",
    Position = 0,
    Mandatory = $false,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $IISLogPath = "C:\inetpub\logs\LogFiles\W3SVC1\",

    [Parameter(
    HelpMessage = "Input Suffix of IIS Log file. Default : u_ex",
    Position = 1,
    Mandatory = $false,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $IISLogFileHead =  "u_ex",

    [Parameter(
    HelpMessage = "Input date of IIS Log file . Default : `"`"",
    Position = 2,
    Mandatory = $false,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
    )]
    [string]
    $IISLogFileDate =  "",

    [Parameter(
    HelpMessage = "Input Extention of IIS Log file. Default : .log",
    Position = 3,
    Mandatory = $false,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
    )]
    [string]
    $IISLogFileExtention =  ".log",

    [Parameter(
    HelpMessage = "Select switch if you want to output with sort all AddressList to Unique. Default : Not Selected",
    Mandatory = $false,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
    )] 
    [switch]
    $sortUniq,

    [Parameter(
    HelpMessage = "If you select this switch, output with csv. Default selected",
    Mandatory = $false,
    ParameterSetName="ExportAsCsv"
    )] 
    [switch]
    $ExportAsCsv,
        
    [Parameter(
    HelpMessage = "If you select this switch, output with json. Default not selected",
    Mandatory = $false,
    ParameterSetName="ExportAsJson"
    )] 
    [switch]
    $ExportAsJson
)



function Get-IisLogFileCIps{

    [CmdletBinding(  
        SupportsShouldProcess = $false,
        ConfirmImpact = "none",
        DefaultParameterSetName = "ExportAsCsv"
    )]
    param
    (
        [Parameter(
        HelpMessage = "Input Path of IIS Log file. Default : C:\inetpub\logs\LogFiles\W3SVC1\",
        Position = 0,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $IISLogPath = "C:\inetpub\logs\LogFiles\W3SVC1\",

        [Parameter(
        HelpMessage = "Input Suffix of IIS Log file. Default : u_ex",
        Position = 1,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $IISLogFileHead =  "u_ex",

        [Parameter(
        HelpMessage = "Input date of IIS Log file . Default : `"`"",
        Position = 2,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $IISLogFileDate =  "",

        [Parameter(
        HelpMessage = "Input Extention of IIS Log file. Default : .log",
        Position = 3,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $IISLogFileExtention =  ".log",

        [Parameter(
        HelpMessage = "Select switch if you want to output with sort all AddressList to Unique. Default : Not Selected",
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )] 
        [switch]
        $sortUniq,

        [Parameter(
        HelpMessage = "If you select this switch, output with csv. Default selected",
        Mandatory = $false,
        ParameterSetName="ExportAsCsv"
        )] 
        [switch]
        $ExportAsCsv,
        
        [Parameter(
        HelpMessage = "If you select this switch, output with json. Default not selected",
        Mandatory = $false,
        ParameterSetName="ExportAsJson"
        )] 
        [switch]
        $ExportAsJson

    )

    begin
    {
        
    }
    
    process
    {
    
        if($IISLogFileDate -ne "")
        {
            $IISLogFullPath = Join-Path $IISLogPath ($IISLogFileHead + $IISLogFileDate + $IISLogFileExtention)
            $IisCertainFlag = $true
        }

        if($IisCertainFlag)
        {
            $logfiles = $IISLogFullPath
        }
        else
        {
            $logfiles = (Get-ChildItem $IISLogPath).FullName
        }

        

        $result = foreach ($log in $logfiles){

            [Console]::WriteLine("$log read start.")

            $IISLogFileRaw = Get-Content -Path $log
            $headers = $IISLogFileRaw[3].Replace("#Fields: ","").split(" ") 
            $IISLogFileCSV = Import-Csv -Delimiter " " -Header $headers -Path $log
            $IISLogFileCSV = $IISLogFileCSV | where {$_.date -notlike "#*"} 
            $IISLogFileCSV `
                | select -ExpandProperty c-ip -Unique `
                | %{
                    try
                    {
                        [System.Net.Dns]::GetHostByAddress($_)
                    }
                    catch
                    {
                    }
                } `
                | %{
                    [PSCustomObject]@{
                        HostName=$_.HostName
                        Aliases=[string]$_.Aliases
                        AddressList=[string]$_.AddressList}
                   }                

            [Console]::WriteLine("$log read end and go next step..")
        }

        [Console]::WriteLine("All Log files read done. Starting output...")
    }

    end
    {
        switch($true){
        $sortUniq {$result | sort AddressList -Unique}
        default {$result | sort AddressList}
        }
    }

}

"Now Running Scripts, please wait"

switch ($true)
{
    $ExportAsCsv { Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" | Export-csv ./IIS_c-IP_lists_$((Get-Date).ToString("yyyyMMdd")).csv -NoTypeInformation}
    $ExportAsJson { Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" | ConvertTo-Json -Compress | Out-File ./IIS_c-IP_lists_$((Get-Date).ToString("yyyyMMdd")).json}
    default { Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" | Export-csv ./IIS_c-IP_lists_$((Get-Date).ToString("yyyyMMdd")).csv -NoTypeInformation}
}

"End Scripts. Please check ./IIS_c-IP_lists.log"

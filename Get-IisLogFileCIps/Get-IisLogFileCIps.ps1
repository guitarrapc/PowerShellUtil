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
        HelpMessage = "Input date of IIS Log file . Sample : `'2013/04/17`'",
        Position = 2,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true      　
        )]
        [string]
        $IISLogFileDate = "",

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
        $prevstatus = $true
    }
    
    process
    {
    
        # Check IIS Log file exit or not, when $IISLogFileDate had passed
        if($IISLogFileDate -ne "")
        {
            # Cast and Perse $IISLogFileDate to use for filename
            $IISLogFileDate = ([datetime]$IISLogFileDate).ToString("yyMMdd")
            
            $IISLogFileName = ($IISLogFileHead + $IISLogFileDate + $IISLogFileExtention)
            $IISLogFullPath = Join-Path $IISLogPath $IISLogFileName
            
            if(!(Test-Path $IISLogFullPath))
            {
                throw "$IISLogFileDate format was correct. But $IISLogFullPath not found. Please check $ISLogFileDate format."
            }

        }
        else
        {
            # When $IISLogFileDate not ordered, then get all Files in iis log directory.
            $IISLogFullPath = (Get-ChildItem $IISLogPath).FullName
        }

        $result = foreach ($log in $IISLogFullPath){

            [Console]::WriteLine("$log read start.")

            # Read $log file
            $IISLogFileRaw = Get-Content -Path $log
            
            # Set Header from log file by reading RAW Number 3
            $headers = $IISLogFileRaw[3].Replace("#Fields: ","").Replace("-","").Replace("(","").Replace(")","").split(" ") 
            
            # Import Log file as Object
            $IISLogFileCSV = Import-Csv -Delimiter " " -Header $headers -Path $log
            
            # Remove #* line for date object
            $IISLogFileCSV = $IISLogFileCSV | where {$_.date -notlike "#*"} 

            # Create PSCustomObject
            $IISLogFileCSV `
                | %{
                    # Input into variables to prepare making PSCustomObject
                    $date=$_.date
                    $time=$_.time
                    $sip=$_.sip
                    $csmethod=$_.csmethod
                    $csuristem=$_.csuristem
                    $csuriquery=$_.csuriquery
                    $sport=$_.sport
                    $csusername=$_.csusername
                    $cip=$_.cip
                    $csUserAgent=$_.csUserAgent
                    $csReferer=$_.csReferer
                    $scstatus=$_.scstatus
                    $scsubstatus=$_.scsubstatus
                    $scwin32status=$_.scwin32status
                    $timetaken=$_.timetaken
                    

                    #region Debug check cip resut
                    <#
                    [Console]::WriteLine($_.cip)
                    #>
                    #endregion

                    # Check currentIP and previousIP is same or not, then check previous result. If failed, then skip.
                    # 1. Check PreviousIP and CurrentIP
                    if(($_.cip -ne $prevCip))
                    {
                        try
                        {
                            # DNS Name Resolve for IP Address who connected
                            [System.Net.Dns]::GetHostByAddress($_.cip)
                            $prevStatus=$true
                        }
                        catch
                        {
                            # Create Custom Object as blank
                            $prevStatus=$false
                            [PSCustomObject]@{
                                HostName=""
                                Aliases=""
                                AddressList=$_.cip
                            }
                        }
                        # flag for next line ip check
                        $prevCip=$_.cip
                    }
                    else
                    {
                        # 2. Check previous result was succeed or not
                        if($prevStatus -eq $false)
                        {
                        }
                        else
                        {
                            [System.Net.Dns]::GetHostByAddress($_.cip)
                            $prevStatus=$true
                        }
                    }


                    #region Debug if result
                    <#
                    [Console]::WriteLine(($_.cip -eq $prevCip) -and ($prevStatus -eq $true))
                    [Console]::WriteLine(($_.cip -eq $prevCip))
                    [Console]::WriteLine(($prevStatus -eq $true))
                    #>
                    #endregion


                } `
                | %{
                    # Output as PSCustomObejct and append all file parse data into 1 PSObject
                    $Output = [PSCustomObject]@{
                        HostName=$_.HostName
                        Aliases=[string]$_.Aliases
                        AddressList=[string]$_.AddressList
                        date=$date
                        time=$time
                        sip=$sip
                        csmethod=$csmethod
                        csuristem=$csuristem
                        csuriquery=$csuriquery
                        sport=$sport
                        csusername=$csusername
                        cip=$cip
                        csUserAgent=$csUserAgent
                        csReferer=$csReferer
                        scstatus=$scstatus
                        scsubstatus=$scsubstatus
                        scwin32status=$scwin32status
                        timetaken=$timetaken
                        iisFileName=$log
                        }

                    # Output currenct PSCustom Object to temp file.
                    switch ($true){
                        $ExportAsCsv {$Output | Out-File ./Current_Object_Status_csv.log}
                        $ExportAsJson {$Output | Out-File ./Current_Object_Status_json.log}
                        default {$Output | Out-File ./Current_Object_Status.log}
                    }
                    
                    # Output to recieve in $result
                    $Output
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


"Now Running Scripts, please wait...."


switch ($true)
{
    $ExportAsCsv 
    { 
        if($true -eq $sortUniq)
        {
            Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" -sortUniq -ExportAsCsv | Export-csv ./IIS_c-IP_lists_$((Get-Date).ToString("yyyyMMdd")).csv -NoTypeInformation
        }
        else
        {
            Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" -ExportAsCsv | Export-csv ./IIS_c-IP_lists_$((Get-Date).ToString("yyyyMMdd")).csv -NoTypeInformation
        }
    }
    
    $ExportAsJson 
    { 
        if($true -eq $sortUniq)
        {
            Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" -sortUniq -ExportAsJson | ConvertTo-Json -Compress | Out-File ./IIS_c-IP_lists_$((Get-Date).ToString("yyyyMMdd")).json
        }
        else
        {
            Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" -ExportAsJson | ConvertTo-Json -Compress | Out-File ./IIS_c-IP_lists_$((Get-Date).ToString("yyyyMMdd")).json
        }       
    }
    
    default { Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" | Export-csv ./IIS_c-IP_lists_$((Get-Date).ToString("yyyyMMdd")).csv -NoTypeInformation}
}

"End Scripts. Please check ./IIS_c-IP_lists.log"
pause
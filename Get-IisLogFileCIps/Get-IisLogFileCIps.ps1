#Requires -Version 3.0

param
(
    [string]
    $IISLogPath = "C:\inetpub\logs\LogFiles\W3SVC1\",
    [string]
    $IISLogFileHead =  "u_ex",
    [string]
    $IISLogFileDate,
    [string]
    $IISLogFileExtention =  ".log",
    [switch]
    $sortUniq
)

function Get-IisLogFileCIps{

    [CmdletBinding()]
    param
    (
        [string]
        $IISLogPath = "C:\inetpub\logs\LogFiles\W3SVC1\",
        [string]
        $IISLogFileHead =  "u_ex",
        [string]
        $IISLogFileDate =  "",
        [string]
        $IISLogFileExtention =  ".log",
        [switch]
        $sortUniq
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
                }

            [Console]::WriteLine("$log read end!! Starting next step..")
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

Get-IisLogFileCIps -IISLogPath "C:\inetpub\logs\LogFiles\W3SVC1\" | Out-File ./IIS_c-IP_lists.log

"End Scripts. Please check ./IIS_c-IP_lists.log"
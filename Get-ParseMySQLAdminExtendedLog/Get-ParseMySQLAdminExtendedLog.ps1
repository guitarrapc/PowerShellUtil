#Requires -Version 3.0

# ---------------------------------------
# MySQL Max Connection Parser
# ---------------------------------------
#
# <<  DESCRIPTION  >>
#
# - This script will pick up value for selected keyword from mysqladmin log.
# - Sample mysqladmin log
#
#
# <<  GET MySQLAdmin extended-status LOG  >>
# 
# Bash output as " mysqladmin -h host -u UserName --password=Password extended-status | grep 'Threads\|connection\|Connection\|Max' >> mysqladmin_extendedstatus.log "
#
#    - MySQLadmin LOG FILE FORMAT -
#
#    ======================================================
#    Fri Apr 19 04:04:20 UTC 2013
#    ------------------------------------------------------
#    | Connections                              | 52853       |
#    | Max_used_connections                     | 843         |
#    | Threads_cached                           | 448         |
#    | Threads_connected                        | 3           |
#    | Threads_created                          | 9872        |
#    | Threads_running                          | 1           |
#    ======================================================
#    ======================================================
#    Fri Apr 19 04:05:20 UTC 2013
#    ------------------------------------------------------
#    | Connections                              | 55853       |
#    | Max_used_connections                     | 950         |
#    | Threads_cached                           | 448         |
#    | Threads_connected                        | 3           |
#    | Threads_created                          | 9995        |
#    | Threads_running                          | 1           |
#    ======================================================
#
#
# <<  OUTPUT SAMPLE  >>
#
# - With this ps1 script, you can select only values for selected keyword of logfile.
#   Just you need to do is select ["Connections" as -Keyword] and [indicate "Path of Logfile" for -Path].
#   Then you will get "52853" and "55853" as returned int value for Value property.
#
#    Value
#    -----
#    52853
#    55853
#
#
# <<  USAGE  >>
#
#   i.e. : Gather "Max_connections" keyword value from logfile located on ".\status_connection_admin.log".
#    
#   Get-ParseMySQLAdminExtendedLog -Keyword Max_used_connections -Path .\status_connection_admin.log
#
#
#   i.e. : If you want Unique values, just add -Unique switch. then value will pass to "Sort-Object Value -Unique" and return.
#
#   Get-ParseMySQLAdminExtendedLog -Keyword Max_used_connections -Path .\status_connection_admin.log -Unique
#
# ---------------------------------------


function Get-ParseMySQLAdminExtendedLog{

    [CmdletBinding(  
        SupportsShouldProcess = $false,
        ConfirmImpact = "none"
    )]
    param
    (
        [Parameter(
        HelpMessage = "Select Connection Parameter Name you want to pickup",
        Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet(
            "Aborted_connects",
            "Connections",
            "Max_used_connections",
            "Threads_cached",
            "Threads_connected",
            "Threads_created",
            "Threads_running"
        )] 
        [string]
        $Keyword,

        [Parameter(
        HelpMessage = "Input Path of Logfile.",
        Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]
        $Path,

        [Parameter(
        HelpMessage = "Select this switch if you want to sort unique for value",
        Position = 2
        )]
        [switch]
        $Unique

    )

    Begin
    {
    }

    Process
    {
        $value = Select-String -Path $Path -CaseSensitive -Pattern $Keyword `
            | %{$_.Line.split("")} `
            | %{
                if($_ -as [int])
                    {
                       [PSCustomObject]@{
                       Value=[int]$_
                    }
                }
            }
    }

    end
    {
        switch($true)
        {
            $Unique {$value | sort Value -Unique}
            default {$value}
        }
    }
}

#region Debug sample
<#
    # output non unique result.
    Get-ParseMySQLAdminExtendedLog -Keyword Max_used_connections -Path .\status_connection_admin.log

    # output unique result.
    Get-ParseMySQLAdminExtendedLog -Keyword Max_used_connections -Path .\status_connection_admin.log -Unique
#>
#endregion
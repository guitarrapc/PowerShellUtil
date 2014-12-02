function Get-LoggedOnUser
{
<#
.Synopsis
    Get Logged on user session information.
.DESCRIPTION
    You can specify with "LogonType and AuthenticationPackage".(Please be sure to use both LogonType and AuthenticationPackage at onece.)
    If you not specify parameters, then all session information will return.
.EXAMPLE
    Get-LoggedOnUser
    # Get all Loged on user information.
.EXAMPLE
    Get-LoggedOnUser -LogonType Interactive -AuthenticationPackage Kerberos
    # Get Interactive logon as Domain(Kerberos) users.
.EXAMPLE
    Get-LoggedOnUser -LogonType Interactive -AuthenticationPackage Kerberos | select -Last 1
    # Get latest Domain Log on user session information.
.EXAMPLE
    Get-LoggedOnUser -LogonType Interactive -AuthenticationPackage Negotiate | select -Last 1
    # Get latest WorkGroup Log on user session information.
#>
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = 0, Position = 0)]
        [ValidateSet("Local System", "Interactive", "Network", "Batch", "Service", "Unlock", "NetworkCleartext", "NewCredentials", "RemoteInteractive", "CachedInteractive")]
        [string]$LogonType = "",

        [Parameter(Mandatory = 0, Position = 0)]
        [ValidateSet("Negotiate", "Kerberos", "NTLM")]
        [string]$AuthenticationPackage = "Kerberos"
    )

    # Logon Type
    $logonTypeHash = @{
        "0"  = "Local System"
        "2"  = "Interactive" #(Local logon)
        "3"  = "Network" # (Remote logon)
        "4"  = "Batch" # (Scheduled task)
        "5"  = "Service" # (Service account logon)
        "7"  = "Unlock" #(Screen saver)
        "8"  = "NetworkCleartext" # (Cleartext network logon)
        "9"  = "NewCredentials" #(RunAs using alternate credentials)
        "10" = "RemoteInteractive" #(RDP\TS\RemoteAssistance)
        "11" = "CachedInteractive" #(Local w\cached credentials)
    }
    
    # Session User Index
    $sessionUser = @{}        
    Get-CimInstance -ClassName Win32_LoggedOnUser `
    | %{
        $username = $_.Antecedent.Domain + "\" + $_.Antecedent.Name
        $session = $_.Dependent.LogonId
        $sessionUser[$session] += $username
    }

    # Logon Session Index matcing User Index
    $result = Get-CimInstance -ClassName Win32_LogonSession
    if ("" -eq $LogonType)
    {
        Write-Verbose "Output all logged on session record."
        return $result `
        | %{
            [PSCustomObject]@{
                Session = $_.LogonId
                User = $sessionUser[$_.LogonId]
                Type = $logonTypeHash[$_.LogonType.ToString()]
                Auth = $_.AuthenticationPackage
                StartTime = $_.StartTime
            }
        }
    }

    Write-Verbose ("Output specific logged on session record. LogonType : {0}, AuthenticationPackage : {1}" -f $LogonType, $AuthenticationPackage)
    $type = ($logonTypeHash.GetEnumerator() | where value -eq $LogonType).Key
    return $result `
    | where LogonType -eq $type `
    | where AuthenticationPackage -eq $AuthenticationPackage `
    | %{
        [PSCustomObject]@{
            Session = $_.LogonId
            User = $sessionUser[$_.LogonId]
            Type = $logonTypeHash[$_.LogonType]
            Auth = $_.AuthenticationPackage
            StartTime = $_.StartTime
        }
    }
}
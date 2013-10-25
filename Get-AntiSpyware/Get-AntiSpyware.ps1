#Requires -Version 3.0

function Get-AntiSpyware
{

<#
.Synopsis
   Get AntiSpyware information

.DESCRIPTION
   Obtain from cim (wmi) as SecutiryCenter shows.
   make sure your OS is Workstation, not as Server. (Because server does not have secutiry Center.)

.EXAMPLE
    # this will obtain from localhost
    Get-AntiSpyware

.EXAMPLE
    # this will obtain from 192.168.100.1 with credential you enter.
    $cred = Get-Credential
    Get-AntiSpyware -computerName 192.168.100.1 -credential $cred

.EXAMPLE
    # this will obtain from 192.168.100.1 with credential you enter.
    $cred = Get-Credential
    "server01","server02" | Get-AntiSpyware -credential $cred

.EXAMPLE
    # Output sample
    --------------------
    isplayName               : Windows Defender
    instanceGuid             : {D68DDC3A-831F-4fae-9E44-DA132C1ACF46}
    pathToSignedProductExe   : %ProgramFiles%\Windows Defender\MSASCui.exe
    pathToSignedReportingExe : %ProgramFiles%\Windows Defender\MsMpeng.exe
    productState             : 397568
    timestamp                : Fri, 25 Oct 2013 14:31:11 GMT
    PSComputerName           : 127.0.0.1
    --------------------    

#>

    [CmdletBinding()]
    Param
    (
        # Input ComputerName you want to check
        [Parameter(Mandatory = 0, 
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName, 
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $computerName = [System.Environment]::MachineName,

        # Input PSCredential for $ComputerName
        [Parameter(Mandatory = 0, 
                   Position=1)]
        [System.Management.Automation.PSCredential]
        $credential
    )

    Begin
    {
        $nameSpace = "SecurityCenter2"
        $className = "AntiSpywareProduct"
    }

    Process
    {
        if ($PSBoundParameters.count -eq 0)
        {
            if ((Get-CimInstance -namespace "root" -className "__Namespace").Name -contains $nameSpace)
            {
                Write-Verbose ("localhost cim session")
                Get-CimInstance -Namespace "root\$nameSpace" -ClassName $className
            }
            else
            {
                Write-Warning ("You can not check AntiSpyware with {0} as it not contain SecutiryCenter2" -f $OSName)
            }
        }
        else
        {
            try
            {
                Write-Verbose ("creating cim session for {0}" -f $computerName)
                $cimSession = New-CimSession @PSBoundParameters
                if ((Get-CimInstance -namespace "root" -className "__Namespace" -cimsession $cimSession).Name -contains $nameSpace)
                {
                    Get-CimInstance -Namespace "root\$nameSpace" -ClassName $className -CimSession $cimSession
                }
                else
                {
                    Write-Warning ("{0} not contains namespace {1}, you can not check {2}." -f $computerName, $nameSpace, $className)
                }
            }
            finally
            {
                $cimSession.Dispose()
            }
        }
    }

    End
    {
    }
}

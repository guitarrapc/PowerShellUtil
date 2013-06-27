function Disable-EnhancedIESecutiry{

    param(
        [bool]
        $IsstatusChanged = $false,

        [string]
        $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}",
    
        [string]
        $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    )

    
    if ((Get-ItemProperty -Path $AdminKey -Name “IsInstalled”).IsInstalled -eq "1")
    {
        Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
        $IsstatusChanged = $true
    }

    if ((Get-ItemProperty -Path $UserKey -Name “IsInstalled”).IsInstalled -eq "1")
    {
        Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
        $IsstatusChanged = $true
    }

    if ($IsstatusChanged)
    {
        Write-Host "IE Enhanced Security Configuration (ESC) has been disabled. Checking IE to stop process." @valemessage

        # Stop Internet Exploer if launch
        Write-Verbose "Checking iexplore process status and trying to kill if exist"
        Get-Process | where Name -eq "iexplore" | Stop-Process
    }
    else
    {
        Write-Host "IE Enhanced Security Configuration (ESC) had already been disabled. Nothing will do." @valemessage
    }

}

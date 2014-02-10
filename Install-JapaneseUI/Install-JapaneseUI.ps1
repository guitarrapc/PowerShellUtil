function Install-JapaneseUI
{
    param
    (
        [parameter(
            mandatory = 1,
            position = 0)]
        [ValidateSet("Windows2012","Windows2012R2")]
        [string]
        $targetOSVersion,

        [parameter(
            mandatory = 0,
            position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $winTemp = "C:\Windows\Temp",

        [parameter(
            mandatory = 0,
            position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]
        $outputRunOncePs1 = "C:\Windows\Temp\SetupLang.ps1",

        [parameter(
            mandatory = 1,
            position = 3)]
        [System.Management.Automation.PSCredential]
        $credential,

        [parameter(
            mandatory = 0,
            position = 4)]
        [switch]
        $force = $false
    )

    begin
    {
        $ErrorActionPreference = "Stop"

        # Set Language Pack URI
        switch ($targetOSVersion)
        {
            "Windows2012"   {
                                [uri]$lpUrl = "http://fg.v4.download.windowsupdate.com/msdownload/update/software/updt/2012/10"
                                $lpFile = "windowsserver2012-kb2607607-x64-jpn_d079f61ac6b2bab923f14cd47c68c4af0835537f.cab"
                            }
            "Windows2012R2" {
                                [uri]$lpurl = "http://fg.v4.download.windowsupdate.com/d/msdownload/update/software/updt/2013/09"
                                $lpfile = "lp_3d6c75e45f3247f9f94721ea8fa1283392d36ea2.cab"
                            }
        }

        $languagePackURI = "$lpurl/$lpfile"

        # set AutoLogin Configuration
        $autoLogonPath = "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        $adminUser = $credential.GetNetworkCredential().UserName
        $adminPassword = $credential.GetNetworkCredential().Password

        # This will run after Installation done and restarted Computer, then first login
        $RunOncePath = "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        $runOnceCmdlet = "
            Set-WinUILanguageOverride ja-JP;                                          # Change Windows UI to Japanese
            Set-WinHomeLocation 122;                                                  # Change Region to Japan
            Set-WinSystemLocal ja-JP                                                  # Set Non-Unicode Program Language to Japanese
            Set-ItemProperty -Path '$autoLogonPath' -Name 'AutoAdminLogon' -Value '0' # Disable AutoAdminLogon
            Remove-ItemProperty -Path '$autoLogonPath' -Name 'DefaultUserName'        # Remove UserName
            Remove-ItemProperty -Path '$autoLogonPath' -Name 'DefaultPassword'        # Remove Password
            Restart-Computer"
    }

    process
    {
        # Japanese UI
        Write-Verbose "Change Win User Language as ja-JP, en-US"
        Set-WinUserLanguageList ja-jp,en-US -Force

        # Set Japanese LanguagePack
        Write-Verbose ("Downloading JP Language Pack from '{0}' to '{1}'" -f $languagePackURI, $winTemp)
        Start-BitsTransfer -Source $languagePackURI -Destination $winTemp

        Write-Verbose ("Installing JP Language Pack from '{0}'" -f $winTemp)
        Add-WindowsPackage -Online -PackagePath (Join-Path $wintemp $lpfile -Resolve)

        Write-Verbose ("Output runonce cmd to execute PowerShell as '{0}'" -f $outputRunOncePs1)
        $runOnceCmdlet | Out-File -FilePath $outputRunOncePs1 -Encoding ascii

        Write-Verbose ("Set RunOnce registry")
        Set-ItemProperty -Path $RunOncePath -Name "SetupLang" -Value "powershell.exe -ExecutionPolicy RemoteSigned -file $outputRunOncePs1"

        # Set Japanese Keyboard : English - LayerDriver JPN : kbd101.dll
        Set-ItemProperty 'registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters' -Name 'LayerDriver JPN' -Value 'kbd106.dll'

        # Auto Login Settings
        Set-ItemProperty -Path $autoLogonPath -Name "AutoAdminLogon" -Value "1"
        Set-ItemProperty -Path $autoLogonPath -Name "DefaultUserName" -Value $adminUser
        Set-ItemProperty -Path $autoLogonPath -Name "DefaultPassword" -Value $adminPassword

        # Restart
        Write-Verbose ("Restart Computer, Make sure Login to")
        Restart-Computer -Confirm -Force:$force
    }
}

# Windows Server 2012 R2 will be ......
#Install-JapaneseUI -targetOSVersion Windows2012 -credential $(Get-Credential -Message "Input Administrator User and Password." -UserName Administrator) -Verbose
# Auto Restart with -force switch
#Install-JapaneseUI -targetOSVersion Windows2012 -credential $(Get-Credential -Message "Input Administrator User and Password." -UserName Administrator) -Verbose -force

# Windows Server 2012 R2 will be ......
#Install-JapaneseUI -targetOSVersion Windows2012R2 -credential $(Get-Credential -Message "Input Administrator User and Password." -UserName Administrator) -Verbose
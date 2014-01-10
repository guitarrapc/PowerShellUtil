function Install-JapaneseUI
{
    param
    (
        [parameter(
            mandatory = 0,
            position = 0)]
        [ValidateNotNullOrEmpty()]
        [uri]
        $lpUrl = "http://fg.v4.download.windowsupdate.com/msdownload/update/software/updt/2012/10",

        [parameter(
            mandatory = 0,
            position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $lpFile = "windowsserver2012-kb2607607-x64-jpn_d079f61ac6b2bab923f14cd47c68c4af0835537f.cab",

        [parameter(
            mandatory = 0,
            position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]
        $winTemp = "C:\Windows\Temp",

        [parameter(
            mandatory = 0,
            position = 3)]
        [ValidateNotNullOrEmpty()]
        [string]
        $outputRunOncePs1 = "C:\Windows\Temp\SetupLang.ps1",

        [parameter(
            mandatory = 1,
            position = 4)]
        [System.Management.Automation.PSCredential]
        $credential
    )

    begin
    {
        $ErrorActionPreference = "Stoo"

        $autoLogonPath = "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        $adminUser = $credential.GetNetworkCredential().UserName
        $adminPassword = $credential.GetNetworkCredential().Password

        # This will run after Installation done and restarted Computer, then first login
        $RunOncePath = "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        $runOnceCmdlet = "
            Set-WinUILanguageOverride ja-JP;
            Set-WinHomeLocation 122;
            Set-WinUserLanguageList -LanguageList ja-jp -Force
            Set-ItemProperty -Path '$autoLogonPath' -Name 'AutoAdminLogon' -Value '0'
            Remove-ItemProperty -Path '$autoLogonPath' -Name 'DefaultUserName'
            Remove-ItemProperty -Path '$autoLogonPath' -Name 'DefaultPassword'
            Restart-Computer"
    }

    process
    {
        # Japanese UI
        Write-Verbose "Change Win User Language as ja-JP, en-US"
        Set-WinUserLanguageList ja-jp,en-US -Force

        # Set Japanese LanguagePack
        Write-Verbose ("Downloading JP Language Pack from '{0}' to '{1}'" -f $lpUrl, $winTemp)
        Start-BitsTransfer -Source $lpurl/$lpfile -Destination $winTemp

        Write-Verbose ("Installing JP Language Pack from '{0}'" -f $winTemp)
        Add-WindowsPackage -Online -PackagePath (Join-Path $wintemp $lpfile -Resolve)

        Write-Verbose ("Output runonce cmd to execute PowerShell as '{0}'" -f $outputRunOncePs1)
        $runOnceCmdlet | Out-File -FilePath $outputRunOncePs1 -Encoding ascii

        Write-Verbose ("Set Runonce registry")
        Set-ItemProperty -Path $RunOncePath -Name "SetupLang" -Value "powershell.exe -ExecutionPolicy RemoteSigned -file $outputRunOncePs1"

        # Set Japanese Keyboard : English - LayerDriver JPN : kbd101.dll
        Set-ItemProperty 'registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters' -Name 'LayerDriver JPN' -Value 'kbd106.dll'

        # Auto Login Settings
        Set-ItemProperty -Path $autoLogonPath -Name "AutoAdminLogon" -Value "1"
        Set-ItemProperty -Path $autoLogonPath -Name "DefaultUserName" -Value $adminUser
        Set-ItemProperty -Path $autoLogonPath -Name "DefaultPassword" -Value $adminPassword

        # Restart
        Write-Verbose ("Restart Computer, Make sure Login to")
        Restart-Computer -Confirm
    }
}

# Windows Server 2012 R2 will be ......
# $lpurl = "http://fg.v4.download.windowsupdate.com/d/msdownload/update/software/updt/2013/09"
# $lpfile = "lp_3d6c75e45f3247f9f94721ea8fa1283392d36ea2.cab"

Install-JapaneseUI -credential $(Get-Credential -Message "Input Administrator User and Password." -UserName Administrator) -Verbose
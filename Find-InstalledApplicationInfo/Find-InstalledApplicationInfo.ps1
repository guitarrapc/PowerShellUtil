function Find-InstalledApplicationInfo{

    $arrayList = New-Object System.Collections.ArrayList
    $reg = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    
    $installedAppsInfos = Get-ItemProperty -Path $reg

    foreach($installedAppsInfo in $installedAppsInfos)
    {
        $obj = [PSCustomObject]@{DisplayName = $installedAppsInfo.DisplayName
                                 DisplayVersion = $installedAppsInfo.DisplayVersion
                                 Publisher = $installedAppsInfo.Publisher}
        $arrayList.Add($obj) > $null
    }
    $arrayList | where DisplayName | sort DisplayName
}
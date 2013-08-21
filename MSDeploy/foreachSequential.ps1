# Sequential foreach execution

$msdeploy = "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe"
$user = "配置管理者ユーザー"
$Password = "配置管理者パスワード"

foreach ($deploygroup in $deploygroups)
{
    # define arguments of msdeploy
    [string[]]$arguments = @(
        "-verb:sync",
        "-source:package=$zip",
        "-dest:auto,computerName=`"http://$deploygroup/MSDeployAgentService`",userName=$user,password=$Password,includeAcls=`"False`"",
        "-disableLink:AppPoolExtension",
        "-disableLink:ContentExtension",
        "-disableLink:CertificateExtension",
        "-setParam:`"IIS Web Application Name`"=`"W3C1hogehoge`"")
                
    # Start Process
    "running msdeploy to $deploygroup" | Out-LogHost -logfile $log -showdata
                                         
        # foreach が sequencial で一向に終わらにゃいお
        Start-Process -FilePath $msdeploy -ArgumentList $arguments -Wait -RedirectStandardOutput $tmplog -RedirectStandardError $tmperrorlog -NoNewWindow
        Get-Content -Path $tmplog -Encoding Default | Out-File -FilePath $log -Encoding utf8 -Append
        Get-Content -Path $tmperrorlog -Encoding Default | Out-File -FilePath $log -Encoding utf8 -Append
        if ($tmplog) {Remove-Item -Path $tmplog -Force}
        if ($tmperrorlog) {Remove-Item -Path $tmperrorlog -Force}
}

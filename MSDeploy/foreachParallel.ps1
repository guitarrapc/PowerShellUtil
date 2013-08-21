# parallel foreach execution

# - msdeploy workflow -#

workflow Invoke-msdeployParallel{
    param(
        [parameter(
            position = 0,
            mandatory)]
        [string[]]
        $deploygroups,

        [parameter(
            position = 1,
            mandatory)]
        [string]
        $msdeploy,

        [parameter(
            position = 2,
            mandatory)]
        [string]
        $zip,

        [parameter(
            position = 3,
            mandatory)]
        [string]
        $user,

        [parameter(
            position = 4,
            mandatory)]
        [string]
        $Password,

        [parameter(
            position = 5,
            mandatory)]
        [string]
        $log,

        [parameter(
            position = 6,
            mandatory)]
        [string]
        $logfolder
    )

    foreach -parallel ($deploygroup in $deploygroups)
    {
        # setup tmplog
        $logfolder = $workflow:logfolder
        $log = $workflow:log
        $ipstring = "$deploygroup".Replace(".","")
        $tmplog = Join-Path -Path $logfolder -ChildPath $("tmp" + $ipstring +".log")
        $tmperrorlog = Join-Path -Path $logfolder -ChildPath $("tmperror" + $ipstring +".log")

        # define arguments of msdeploy
        [string[]]$arguments = @(
            "-verb:sync",
            "-source:package=$workflow:zip",
            "-dest:auto,computerName=`"http://$deploygroup/MSDeployAgentService`",userName=$($workflow:user),password=$($workflow:Password),includeAcls=`"False`"",
            "-disableLink:AppPoolExtension",
            "-disableLink:ContentExtension",
            "-disableLink:CertificateExtension",
            "-setParam:`"IIS Web Application Name`"=`"W3C1hogehoge`"")
                
        # Start Process
        $msdeploy = $workflow:msdeploy
        Write-Warning -Message "[$(Get-Date)][message][""running msdeploy to $deploygroup""]"
        "[$(Get-Date)][message][""running msdeploy to $deploygroup""]" | Out-File -FilePath $tmplog -Encoding utf8 -Append
            Start-Process -FilePath $msdeploy -ArgumentList $arguments -Wait -RedirectStandardOutput $tmplog -RedirectStandardError $tmperrorlog -NoNewWindow
    }
}


$msdeploy = "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe"
$user = "配置管理者ユーザー"
$Password = "配置管理者パスワード"

# remove old tmp log files
Get-ChildItem -Path $logfolder -Filter "tmp*" | Remove-Item -Force

# run msdeploy
Invoke-msdeployParallel -deploygroups $deploygroups -msdeploy $msdeploy -zip $zip -user $user -Password $Password -log $log -logfolder $logfolder

# Read Logfiles
$result = @()
foreach ($deploygroup in $deploygroups)
{
    # setup tmplog
    $logfolder = $logfolder
    $log = $log
    $ipstring = "$deploygroup".Replace(".","")
    $tmplog = Join-Path -Path $logfolder -ChildPath $("tmp" + $ipstring +".log")
    $tmperrorlog = Join-Path -Path $logfolder -ChildPath $("tmperror" + $ipstring +".log")
                    
    $result += "[$((Get-Item $tmplog).LastWriteTime)][message][Result of MSDeploy for {$deploygroup}]"
    $result += Get-Content -Path $tmplog -Encoding Default -Raw
    $result += Get-Content -Path $tmperrorlog -Encoding Default -Raw
}

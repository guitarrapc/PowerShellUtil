filter Out-LogHost{
        
    param(
        [string]
        $logfile,

        [switch]
        $message,

        [switch]
        $showdata,

        [switch]
        $hidedata,

        [switch]
        $error
    )


    if($message)
    {
        Write-Host "$_`n" -ForegroundColor Cyan
        "[$(Get-Date)][message][$_]" | Out-File $logfile -Encoding utf8 -Append -Width 1024
    }
    elseif($showdata)
    {
        $_
        $_ | Out-File $logfile -Encoding utf8 -Append -Width 1024
    }
    elseif($hidedata)
    {
        $_ | Out-File $logfile -Encoding utf8 -Append -Width 1024
    }
    elseif($error)
    {
        $_ | Out-File $logfile -Encoding utf8 -Append -Width 1024
        throw $_
    }
}


$log = "d:\message.log"
"hogehoge" | Out-LogHost -logfile $log -message

$log = "d:\hidedata.log"
ps | select -First 1 | Out-LogHost -logfile $log -hidedata

$log = "d:\showdata.log"
ps | select -First 1 | Out-LogHost -logfile $log -showdata

$log = "d:\error.log"
try
{
    ps -Name hoge -ErrorAction Stop
}
catch
{
    $_ | Out-LogHost -logfile $log -error
}


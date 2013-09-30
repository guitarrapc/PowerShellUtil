# Auto Recover Application Event Pool Stopped Instance

$timer = New-Object System.Timers.Timer
$timer.Interval = 1000
$timer.AutoReset = $true


Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {

    $start = Get-Date -Format O
    sleep 1
    $end = Get-Date -Format O
    $hoge = [PSCustomObject]@{
        Start = $start
        End = $end
        Duration = ([datetime]$start - [datetime]$end).TotalSeconds
    }
    Write-Host $hoge -ForegroundColor Cyan
}


Sleep -Seconds 1
$timer.Start()


# $timer.Stop()


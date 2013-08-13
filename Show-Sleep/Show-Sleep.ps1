$sleepSec = 10
foreach ($i in (1..$sleepSec))
{
    Write-Progress -Activity "wait for $sleepsec sec...." -Status "Waiting... $i sec" -PercentComplete (($i/$sleepsec)*100)
    sleep -Seconds 1
}

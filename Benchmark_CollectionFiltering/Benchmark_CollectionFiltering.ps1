# -- stopwatch function -- #

function Measure-Stopwatch{

    [CmdletBinding()]
    param(
    [parameter(Mandatory=$true)]
    [ScriptBlock]$Command,
    [switch]$Days,
    [switch]$Hours,
    [switch]$Minutes,
    [switch]$Seconds,
    [switch]$Milliseconds
    )

    $sw = New-Object System.Diagnostics.StopWatch
    
    # Start Stopwatch
    $sw.Start()

    #TargetCommand to measure
    $command.Invoke()
    
    # Stop Stopwatch
    $sw.Stop()
    
    #Show Result
    switch ($true){
        $Days {$sw.Elapsed.TotalDays}
        $Hours {$sw.Elapsed.TotalHours}
        $Minutes {$sw.Elapsed.TotalMinutes}
        $Seconds {$sw.Elapsed.TotalSeconds}
        $Milliseconds {$sw.Elapsed.TotalMilliseconds}
        default {$sw.Elapsed}
    }

    #Reset Result
    $sw.Reset()
    
}


# -- define repeat count -- #

$repeat = 1000

# -- test ScriptBlock -- #

$ps1Where = {
    foreach ($r in 1..$repeat)
    {
        Get-Process | where { $_.Name -eq "powershell_ise" } > $null
    }
}

$ps3Where = {
    foreach ($r in 1..$repeat)
    {
        Get-Process | where Verb -eq "powershell_ise" > $null
    }
}

$ps4Where = {
    foreach ($r in 1..$repeat)
    {
        (Get-Process).Where({$_.Name -eq "powershell_ise"}) > $null
    }
}

$Filter= {
    filter filterCommand {if ($_.Name -eq "powershell_ise"){$_}}
    foreach ($r in 1..$repeat)
    {
        Get-Process | filterCommand > $null
    }
}

$Foreach = {
    foreach ($r in 1..$repeat)
    {
        foreach ($process in Get-Process)
        {
            if ($process.Name -eq "powershell_ise")
            {
                $process > $null
            }
        }
    }
}


# -- start main -- #

Write-Host "running ps1- Where-Object cluese" -ForegroundColor DarkGray
$PS1Millisec = Measure-Stopwatch -Command $ps1Where -Milliseconds

Write-Host "running ps3- Where-Object Simplfied syntax" -ForegroundColor DarkGray
$PS3Millisec = Measure-Stopwatch -Command $ps3Where -Milliseconds

Write-Host "running ps4 Where method collection" -ForegroundColor DarkGray
$PS4Millisec = Measure-Stopwatch -Command $ps4Where -Milliseconds

Write-Host "running Filter collection test" -ForegroundColor DarkGray
$FilterMillisec = Measure-Stopwatch -Command $Filter -Milliseconds

Write-Host "running Foreach conditional collection" -ForegroundColor DarkGray
$ForeachMillisec = Measure-Stopwatch -Command $Foreach -Milliseconds


# -- show result -- #

New-Object PSObject -Property ([ordered]@{
    "ps1[ms]"     = $ps1Millisec
    "ps3[ms]"     = $ps3Millisec
    "ps4[ms]"     = $ps4Millisec
    "filter[ms]"  = $FilterMillisec
    "foreach[ms]" = $ForeachMillisec
}) | Format-List
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

    function Start-InputScriptBlock {
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

    Start-InputScriptBlock
    
}

$hoge = 1..10000
#Measure-Stopwatch -Command {Write-Output $hoge}
#Measure-Stopwatch -Command {Write-Host $hoge}
#Measure-Stopwatch -Command {[Console]::WriteLine("$hoge")}
Measure-Stopwatch -Command {1..1000 | %{Get-Date}} | select -last 1
Measure-Stopwatch -Command {1..1000 | %{Get-Date}} | select -last 1 | select TotalMilliseconds
Measure-Command {1..1000 | %{Get-Date}}

Measure-Command {Get-Date}
Measure-Stopwatch {Get-Date}
Measure-Stopwatch -Command {Get-Date} | select -Last 1

”--------------------------------”
Measure-Command {Get-Date}
Measure-Stopwatch -Command {Get-Date} 
Measure-Stopwatch {Get-Date} 
Measure-Stopwatch -Command {Get-Date} -Milliseconds
(Measure-Stopwatch -Command {Get-Date}).TotalMilliseconds
Measure-Stopwatch -Command {Get-Date} | select -Last 1
(Measure-Command {Get-Date}).TotalMilliseconds

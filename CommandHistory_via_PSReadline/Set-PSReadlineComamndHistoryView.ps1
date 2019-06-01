# modified : https://stackoverflow.com/questions/50376858/making-the-command-history-pop-up-work-via-f7-in-windows-10-powershell
Set-PSReadlineKeyHandler -Key F7 -BriefDescription "History" -LongDescription "Show command history" -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $pattern, [ref] $null)
    if ( $pattern ) {
        $pattern = [Regex]::Escape($pattern)
    }
    $history = [System.Collections.ArrayList] @(
        $last = ""
        $lines = ""
        foreach ( $line in [System.IO.File]::ReadLines((Get-PSReadlineOption).HistorySavePath) ) {
            if ( $line.EndsWith('`') ) {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ( $lines ) { "$lines`n$line" } else { $line }
                continue
            }
            if ( $lines ) {
                $line = "$lines`n$line"
                $lines = ""
            }
            if ( ($line -cne $last) -and ((-not $pattern) -or ($line -match $pattern)) ) {
                $last = $line
                $line
            }
        }
    )
    # acs
    # $command = $history | Out-GridView -Title History -PassThru
    # desc
    $command = $history | Sort-Object -Descending | Out-GridView -Title History -PassThru
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}
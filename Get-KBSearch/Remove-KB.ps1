param(
    [string]
    $kb="KB2821895"
)


Get-WmiObject -Class Win32_QuickFixEngineering `
    | %{ 
        if($_.HotFixID -eq $kb)
        {
            "$kb found. Opening application list, let's uninstall $kb."
            Invoke-Command {appwiz.cpl}
        }
        else
        {
            "$kb not found. Lucky you!"
        }
    } `
    | sort -Unique `
    | select -First 1


$PatchList = Get-WmiObject Win32_QuickFixEngineering | where HotFixId -eq $kb

foreach ($k in $PatchList)
{
    # Write-Host $Patch.HotfixId

    # If the HotfixID property contains any text, remove it (some do, some don't)
    $KBNumber = $k.HotfixId.Replace("KB", "")
    
    # Write-Host $KBNumber
    
    # Build our command line for removing the update
    $RemovalCommand = "wusa.exe /uninstall /kb:$KBNumber /quiet /log /norestart"
    Write-Host ("Removing update with command: " + $RemovalCommand)

    # Invoke the command we built above
    Invoke-Expression $RemovalCommand

    # Wait for wusa.exe to finish and exit (wusa.exe actually leverages
    # TrustedInstaller.exe, so you won't see much activity within the wusa process)
    while (@(Get-Process wusa -ErrorAction SilentlyContinue).Count -ne 0)
    {
        Start-Sleep 1
        Write-Host "Waiting for update removal to finish ..."
    }
}
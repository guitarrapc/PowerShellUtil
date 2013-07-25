function Remove-KB{
    param(
	    [parameter(
	    mandatory,
	    position = 0)]
	    [string[]]
	    $kbs
    )

    $PatchList = Get-WmiObject Win32_QuickFixEngineering | where HotFixId -in $kbs

    foreach ($k in $PatchList)
    {
        # If the HotfixID property contains any text, remove it (some do, some don't)
        $KBNumber = $k.HotfixId.Replace("KB", "")
	    
        # Write-Host $KBNumber
        Write-Host ("Removing update with command: " + $RemovalCommand)

        # Build command line for removing the update
        $RemovalCommand = "wusa.exe /uninstall /kb:$KBNumber /quiet /log /norestart"

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
}

Remove-KB -kbs "KB2821895"
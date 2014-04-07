function Restart-PowershellHost
{
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact='High')] 
    Param
    (
        [switch]
        $AsAdministrator,

        [switch]
        $Force
    )
    
    process
    {
        if ($Force -or $PSCmdlet.ShouldProcess($proc.Name, "Restart the console as administrator : '{0}'" -f $AsAdministrator))    # comfirmation to restart
        {
            if (($host.Name -eq 'Windows PowerShell ISE Host') -and ($psISE.PowerShellTabs.Files.IsSaved -contains $false))        # ise detect and unsave tab check
            {
                if ($Force -or $PSCmdlet.ShouldProcess('Unsaved work detected?','Unsaved work detected. Save changes?','Confirm')) # ise tab save dialog
                {
                    # dialog selected yes.
                    $psISE.PowerShellTabs | Start-SaveAndCloseISETabs
                }
                else
                {
                    # dialog selected no.
                    $psISE.PowerShellTabs | Start-CloseISETabs
                }
            }

            #region restart host process
            Write-Debug ("Start new host : '{0}'" -f $proc.Name)
            Start-Process @params

            Write-Debug ("Close old host : '{0}'" -f $proc.Name)
            $proc.CloseMainWindow()
            #endregion
        }
    }

    begin
    {
        $proc = Get-Process -Id $PID
 
        #region Setup parameter for restart host
        $params = @{
            FilePath = $proc.Path
        }

        if ($AsAdministrator)
        {
            $params.Verb = 'runas'
        }

        if ($cmdArgs)
        {
            $params.ArgumentList = [Environment]::GetCommandLineArgs() | Select-Object -Skip 1
        }
        #endregion

        #region internal function to close ise with save
        filter Start-SaveAndCloseISETabs
        {
            $_.Files `
            | % { 
                if($_.IsUntitled -and (-not $_.IsSaved))
                {
                    $_.SaveAs($_.FullPath, [System.Text.Encoding]::UTF8)
                }
                elseif(-not $_.IsSaved)
                {
                    $_.Save()
                }
            }
        }
        #endregion

        #region internal function to close ise without save
        filter Start-CloseISETabs
        {
            $ISETab = $_
            $unsavedFiles = $IseTab.Files | where IsSaved -eq $false
            $unsavedFiles | % {$IseTab.Files.Remove($_,$true)}
        }
        #endregion
    }
}
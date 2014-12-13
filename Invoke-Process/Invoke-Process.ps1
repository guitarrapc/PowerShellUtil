function Invoke-Process
{
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = 0, Position = 0)]
        [string]$FileName = "PowerShell.exe",

        [Parameter(Mandatory = 0, Position = 1)]
        [string]$Arguments = "",
        
        [Parameter(Mandatory = 0, Position = 2)]
        [string]$WorkingDirectory = ".",

        [Parameter(Mandatory = 0, Position = 3)]
        [int]$TimeoutMS = 120000
    )

    end
    {
        try
        {
            # new Process
            $process = NewProcess -FileName $FileName -Arguments $Arguments -WorkingDirectory $WorkingDirectory
                
            # Event Handler for Output
            $stdEvent = Register-ObjectEvent -InputObject $process -EventName OutputDataReceived -Action $scripBlock -MessageData $stdSb
            $errorEvent = Register-ObjectEvent -InputObject $process -EventName ErrorDataReceived -Action $scripBlock -MessageData $errorSb

            # execution
            $process.Start() > $null
            $process.BeginOutputReadLine()
            $process.BeginErrorReadLine()

            # wait for complete
            WaitProcessComplete -Process $process -TimeoutMS $TimeoutMS

            # verbose Event Result
            $stdEvent, $errorEvent | VerboseOutput

            # output
            return GetCommandResult -Process $process -StandardStringBuilder $stdSb -ErrorStringBuilder $errorSb
        }
        finally
        {
            if ($null -ne $process){ $process.Dispose() }
            if ($null -ne $stdEvent){ Unregister-Event -SourceIdentifier $stdEvent.Name }
            if ($null -ne $errorEvent){ Unregister-Event -SourceIdentifier $errorEvent.Name }
            if ($null -ne $stdEvent){ $stdEvent.Dispose() }
            if ($null -ne $errorEvent){ $errorEvent.Dispose() }        
        }
    }

    begin
    {
        # Prerequisites       
        $stdSb = New-Object -TypeName System.Text.StringBuilder
        $errorSb = New-Object -TypeName System.Text.StringBuilder
        $scripBlock = 
        {
            if (-not [String]::IsNullOrEmpty($EventArgs.Data))
            {
                        
                $Event.MessageData.AppendLine($Event.SourceEventArgs.Data)
            }
        }

        function NewProcess ([string]$FileName, [string]$Arguments, [string]$WorkingDirectory)
        {
            "Execute command : '{0} {1}', WorkingSpace '{2}'" -f $FileName, $Arguments, $WorkingDirectory | VerboseOutput
            # ProcessStartInfo
            $psi = New-object System.Diagnostics.ProcessStartInfo 
            $psi.CreateNoWindow = $true
            $psi.LoadUserProfile = $true
            $psi.UseShellExecute = $false
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.FileName = $FileName
            $psi.Arguments+= $Arguments
            $psi.WorkingDirectory = $WorkingDirectory

            # Set Process
            $process = New-Object System.Diagnostics.Process 
            $process.StartInfo = $psi
            return $process
        }

        function WaitProcessComplete ([System.Diagnostics.Process]$Process, [int]$TimeoutMS)
        {
            "Waiting for command complete. It will Timeout in {0}ms" -f $TimeoutMS | VerboseOutput
            $isComplete = $Process.WaitForExit($TimeoutMS)
            if (-not $isComplete)
            {
                "Timeout detected for {0}ms. Kill process immediately" -f $timeoutMS | VerboseOutput
                $Process.Kill()
                $Process.CancelOutputRead()
                $Process.CancelErrorRead()
            }
        }

        function GetCommandResult ([System.Diagnostics.Process]$Process, [System.Text.StringBuilder]$StandardStringBuilder, [System.Text.StringBuilder]$ErrorStringBuilder)
        {
            'Get command result string.' | VerboseOutput
            return [PSCustomObject]@{
                StandardOutput = $StandardStringBuilder.ToString()
                ErrorOutput = $ErrorStringBuilder.ToString()
                ExitCode = $process.ExitCode
            }
        }

        filter VerboseOutput
        {
            $_ | Out-String -Stream | Write-Verbose
        }
    }
}

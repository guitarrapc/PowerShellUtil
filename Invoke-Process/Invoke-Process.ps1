function Invoke-Process
{
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$FileName = "PowerShell.exe",

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$Arguments = "",
        
        [Parameter(Mandatory = $false, Position = 2)]
        [string]$WorkingDirectory = ".",

        [Parameter(Mandatory = $false, Position = 3)]
        [TimeSpan]$Timeout = [System.TimeSpan]::FromMinutes(2)
    )

    end
    {
        try
        {
            # new Process
            $process = NewProcess -FileName $FileName -Arguments $Arguments -WorkingDirectory $WorkingDirectory
            
            # Event Handler for Output
            $stdSb = New-Object -TypeName System.Text.StringBuilder
            $errorSb = New-Object -TypeName System.Text.StringBuilder
            $scripBlock = 
            {
                $x = $Event.SourceEventArgs.Data
                if (-not [String]::IsNullOrEmpty($x))
                {
                    [System.Console]::WriteLine($x)
                    $Event.MessageData.AppendLine($x)
                }
            }
            $stdEvent = Register-ObjectEvent -InputObject $process -EventName OutputDataReceived -Action $scripBlock -MessageData $stdSb
            $errorEvent = Register-ObjectEvent -InputObject $process -EventName ErrorDataReceived -Action $scripBlock -MessageData $errorSb

            # execution
            $process.Start() > $null
            $process.BeginOutputReadLine()
            $process.BeginErrorReadLine()
            
            # wait for complete
            "Waiting for command complete. It will Timeout in {0}ms" -f $Timeout.TotalMilliseconds | VerboseOutput
            $isTimeout = $false
            if (-not $Process.WaitForExit($Timeout.TotalMilliseconds))
            {
                $isTimeout = $true
                "Timeout detected for {0}ms. Kill process immediately" -f $Timeout.TotalMilliseconds | VerboseOutput
                $Process.Kill()
            }
            $Process.WaitForExit()
            $Process.CancelOutputRead()
            $Process.CancelErrorRead()

            # verbose Event Result
            $stdEvent, $errorEvent | VerboseOutput

            # Unregister Event to recieve Asynchronous Event output (You should call before process.Dispose())
            Unregister-Event -SourceIdentifier $stdEvent.Name
            Unregister-Event -SourceIdentifier $errorEvent.Name

            # verbose Event Result
            $stdEvent, $errorEvent | VerboseOutput

            # Get Process result
            return GetCommandResult -Process $process -StandardStringBuilder $stdSb -ErrorStringBuilder $errorSb -IsTimeOut $isTimeout
        }
        finally
        {
            if ($null -ne $process){ $process.Dispose() }
            if ($null -ne $stdEvent){ $stdEvent.Dispose() }
            if ($null -ne $errorEvent){ $errorEvent.Dispose() }
        }
    }

    begin
    {
        function NewProcess
        {
            [OutputType([System.Diagnostics.Process])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [string]$FileName,
                
                [parameter(Mandatory = $false)]
                [string]$Arguments,
                
                [parameter(Mandatory = $false)]
                [string]$WorkingDirectory
            )

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
            $process.EnableRaisingEvents = $true
            return $process
        }

        function GetCommandResult
        {
            [OutputType([PSCustomObject])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [System.Diagnostics.Process]$Process,

                [parameter(Mandatory = $true)]
                [System.Text.StringBuilder]$StandardStringBuilder,

                [parameter(Mandatory = $true)]
                [System.Text.StringBuilder]$ErrorStringBuilder,

                [parameter(Mandatory = $true)]
                [Bool]$IsTimeout
            )
            
            'Get command result string.' | VerboseOutput
            return [PSCustomObject]@{
                StandardOutput = $StandardStringBuilder.ToString().Trim()
                ErrorOutput = $ErrorStringBuilder.ToString().Trim()
                ExitCode = $Process.ExitCode
                IsTimeOut = $IsTimeout
            }
        }

        filter VerboseOutput
        {
            $_ | Out-String -Stream | Write-Verbose
        }
    }
}

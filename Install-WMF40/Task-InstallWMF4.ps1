#Requires -Version 3.0
# Make sure your OS Version is Windows Server 2012

function Main
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 0,
            Position  = 0)]
        [uri]
        $uri = "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows8-RT-KB2799888-x64.msu",
            
        [parameter(
            Mandatory = 0,
            Position  = 1)]
        [string]
        $DownloadFolder = "C:\Download"
    )

    # Download
    $fileName = Split-Path $uri -Leaf
    $path = Join-Path $DownloadFolder $FileName
    New-Item -Path $DownloadFolder -ItemType Directory -Force > $null
    Invoke-ScriptBlockEX -scriptBlock {Invoke-DownloadFileEX -uri $uri -path $path} -WhatDoing "Downloading WMF4.0 Setup file."
    
    # Extract
    if (Test-Path $path)
    {
        $extractPath = Join-Path $DownloadFolder "extract"
        New-Item -Path $extractPath -ItemType Directory -Force > $null
        Invoke-ScriptBlockEX -scriptBlock {Start-ProcessEX -exe "C:\Windows\System32\wusa.exe" -arguments "$path /extract:$extractPath"} -WhatDoing "Extract msu to cab."
    }
    else
    {
        Write-Warning "$path not found."
    }

    # Install
    if (($cabs = Get-ChildItem $extractPath | where Extension -eq ".cab").count -ne 0)
    {
        $cabName = $cabs | where Name -eq ([IO.Path]::ChangeExtension($fileName,"cab"))
        $cabPath = Join-Path $extractPath $cabName
        Invoke-ScriptBlockEX -scriptBlock {Start-ProcessEX -exe "C:\Windows\System32\dism.exe" -arguments "/Online /Add-package /PackagePath:$cabPath /NoRestart /Quiet"} -WhatDoing "Install WMF4.0 cab. Please Restart after installation."
    }
    else
    {
        Write-Warning "cab not found."
    }

    # Remove
    if (Test-Path $extractPath)
    {
        Invoke-ScriptBlockEX -scriptBlock {Remove-Item -Path $extractPath -Recurse -Force} -WhatDoing "Remove All Download file and Packages."
    }
    else
    {
        Write-Warning "$extractPath not found."
    }
}

filter Show-LogoutputEX
{
    "[{0}][{1}][{2}]" -f ((Get-Date).ToString("yyyy/MM/dd HH:mm:ss")),$_[0], $_[1]
}

function Invoke-ScriptBlockEX ([scriptBlock]$scriptBlock, [string]$WhatDoing)
{
    begin
    {
        $sw = New-Object System.Diagnostics.Stopwatch
        $sw.Start()
        ,@("started", $WhatDoing) | Show-LogoutputEX
    }
    process
    {
        & $scriptBlock
    }
    end
    {
        $sw.Stop()
        ,@("finished", ("{0} : {1}ms" -f $WhatDoing, $sw.ElapsedMilliseconds)) | Show-LogoutputEX
    }
}

function Invoke-DownloadFileEX ([uri]$uri, [string]$path)
{
    try
    {
        Add-Type -AssemblyName System.Net.Http
        $httpClient = New-Object Net.Http.HttpClient
        $responseMessage = $httpClient.GetAsync($uri, [System.Net.Http.HttpCompletionOption]::ResponseContentRead)
    
        $fileStream = [System.IO.File]::Create($path)
        $httpStream = $responseMessage.Result.Content.ReadAsStreamAsync()
        $httpStream.ConfigureAwait($false) > $null
        $httpStream.Result.CopyToAsync($fileStream).Wait()
        $fileStream.Flush()
    }
    finally
    {
        $fileStream.Dispose()
        $httpClient.Dispose()
    }
}

function Start-ProcessEX ([string]$exe, [string]$arguments)
{
    $psi                        = New-object System.Diagnostics.ProcessStartInfo 
    $psi.CreateNoWindow         = $true 
    $psi.UseShellExecute        = $false 
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.FileName               = $exe
    $psi.Arguments              = $arguments

    $process                    = New-Object System.Diagnostics.Process 
    $process.StartInfo          = $psi
    $process.Start()            > $null
    $output                     = $process.StandardOutput.ReadToEnd()
    $outputError                = $process.StandardError.ReadToEnd()
    $process.StandardOutput.ReadLine()
    $process.WaitForExit() 
                    
    $output
    $outputError
}

# execute
Main

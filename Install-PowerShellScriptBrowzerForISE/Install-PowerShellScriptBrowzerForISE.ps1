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

# Download
# Script Browser 1.1
# [uri]$uri = "http://download.microsoft.com/download/0/B/B/0BBAA3D7-3B61-4830-86CE-D93408D7AABD/ScriptBrowser.msi"
# Script Browser 1.3
[uri]$uri = "http://download.microsoft.com/download/0/B/B/0BBAA3D7-3B61-4830-86CE-D93408D7AABD/ScriptBrowser.exe"

$DownloadFolder = "C:\Download"
$fileName = Split-Path $uri -Leaf
$path = Join-Path $DownloadFolder $FileName
New-Item -Path $DownloadFolder -ItemType Directory -Force > $null
Invoke-ScriptBlockEX -scriptBlock {Invoke-DownloadFileEX -uri $uri -path $path} -WhatDoing "Downloading WMF4.0 Setup file."
    
# Install
if (Test-Path $path)
{
    Invoke-ScriptBlockEX -scriptBlock {Start-ProcessEX -exe "C:\Windows\System32\msiexec.exe" -Arguments "/i $path"} -WhatDoing "Install msi."
}
else
{
    Write-Warning "$path not found."
}

# Remove
if (Test-Path $path)
{
    Invoke-ScriptBlockEX -scriptBlock {Remove-Item -Path $path -Recurse -Force} -WhatDoing "Remove All Download file and Packages."
}
else
{
    Write-Warning "$path not found."
}

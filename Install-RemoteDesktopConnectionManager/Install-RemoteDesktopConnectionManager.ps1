# Define
$software = "RDCMan.msi"
$path = Join-Path "Path to Installer (c:\hogehoge)" $software
$destination = Join-Path "C:\Windows\Temp" $software

# run
if (Test-Path $path)
{
    try
    {
        # Copy Software
        Copy-Item -Path $path -Destination $destination -Force -ErrorAction Stop
    }
    catch
    {
        throw $_
    }

    # install Software
    if (Test-Path $destination)
    {
        try
        {
            Start-Process -FilePath $destination -ArgumentList "/m /quiet /passive"
            Write-Host "Installation Complete" -ForegroundColor Cyan
        }
        catch
        {
            throw $_
        }
    }
    else
    {
        Write-Warning "$destination not found!"
    }
}
else
{
    Write-Warning "$path not found!"
}



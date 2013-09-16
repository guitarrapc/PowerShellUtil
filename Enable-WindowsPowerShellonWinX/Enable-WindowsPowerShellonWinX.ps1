$PowerShellPath = "registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$PowerShellKey = "DontUsePowerShellOnWinX"

# Check Win + X Shell Status
(Get-ItemProperty -Path $PowerShellPath).$PowerShellKey

# Disable PowerShell on Win + X
Set-ItemProperty -Path $PowerShellPath -Name $PowerShellKey -Value 1 -PassThru

# Enable PowerShell on Win + X
Set-ItemProperty -Path $PowerShellPath -Name $PowerShellKey -Value 0 -PassThru

# Restart Explorer.exe then change take effect
Get-Process | where Name -eq Explorer |Stop-Process -Force -PassThru | %{Start-Process C:\Windows\explorer.exe}
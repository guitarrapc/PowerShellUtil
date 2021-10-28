# Run on Windwos PowerShell or pwsh. Don't needd Administrator Priviledge
# BusType 17 = NVMe, 11 = SATA, 7 = USB. see https://docs.microsoft.com/en-us/previous-versions/windows/desktop/stormgmt/msft-disk
Get-CimInstance -namespace Root\Microsoft\Windows\Storage -class msft_physicaldisk | select FriendlyName, BusType
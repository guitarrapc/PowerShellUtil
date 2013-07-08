# Create SMB Mapping
New-SmbMapping -LocalPath z: -RemotePath \\127.0.0.1\Users -Persistent $true -UserName -Password

# Get SMB Mapping
Get-SmbMapping

# Remove SMB Mapping
Remove-SmbMapping -LocalPath z: -Force

# Use CIM Session for secure credential
$Credential = Get-Credential
$CimSession = New-CimSession -ComputerName hogehoge -Credential $Credential
New-SmbMapping -LocalPath z: -RemotePath \\hogehoge\Users -Persistent $true -CimSession $CimSession

# PS-Drive with credential
$SharePath = "\\共有したいドライブパス"
$DriveName = "空いてるドライブ名"
if(-not ((Get-PSDrive).DisplayRoot -contains $SharePath))
{
	New-PSDrive -Name $DriveName -PSProvider FileSystem -Root $SharePath -Credential　$Credential -Persist
}

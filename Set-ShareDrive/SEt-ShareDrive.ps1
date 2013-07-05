$SharePath = "\\共有したいドライブパス"
$DriveName = "空いてるドライブ名"
if(-not ((Get-PSDrive).DisplayRoot -contains $SharePath))
{
	New-PSDrive -Name $DriveName -PSProvider FileSystem -Root $SharePath -Persist
}
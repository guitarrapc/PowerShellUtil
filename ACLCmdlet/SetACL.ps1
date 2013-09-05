$objUser = New-Object System.Security.Principal.NTAccount("Administrators")
$Rights = [System.Security.AccessControl.FileSystemRights]"FullControl"
$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::None
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
$objType = [System.Security.AccessControl.AccessControlType]::Allow

$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule ($objUser, $Rights, $InheritanceFlag, $PropagationFlag, $objType)

$objACL = Get-ACL "C:\test12"
$objACL.SetAccessRule($objACE)
Set-Acl -Path C:\test -AclObject $objACL
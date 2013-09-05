$objACL = Get-ACL "C:\test12"
$permission = "BUILTIN\IIS_IUSRS","Read, Write","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$objACL.SetAccessRule($accessRule)

Set-Acl -Path C:\test -AclObject $objACL
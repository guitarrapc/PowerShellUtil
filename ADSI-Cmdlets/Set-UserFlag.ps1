$excludeuser = "Administrator","Guest"
$HostPC = [System.Environment]::MachineName

# PowerShell V2.0 ‚Ü‚Å‚Ì‚â‚è•û
# $adsi = [ADSI]("WinNT://" + $HostPc)
# $users = ($adsi.psbase.children | where {$_.psbase.schemaClassName -match "user"} | where Name -notin $excludeuser).Name

# PowerShell V3.0 ‚Å‚Í cim ‚©‚çŽæ“¾‰Â”\
$users = (Get-CimInstance -ClassName Win32_UserAccount | where Name -notin $excludeuser).Name

foreach ($user in $users)
{
    $targetuser = [ADSI]("WinNT://{0}/{1}, user" -F $HostPC, $user)
    Write-Warning "Setting user [$($targetuser.name)] as password not expire."
    $userFlags = $targetuser.Get("UserFlags")
    $userFlags = $userFlags -bor 0x10000 # 0x10040 will "not expire + not change password"
    $targetuser.Put("UserFlags", $userFlags)
    $targetuser.SetInfo()
}
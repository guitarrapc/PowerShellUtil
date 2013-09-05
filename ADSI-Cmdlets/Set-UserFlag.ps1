$HostPC = [System.Environment]::MachineName
$adsi = [ADSI]("WinNT://" + $HostPc)
$users = ($adsi.psbase.children | where {$_.psbase.schemaClassName -match "user"}).Name

foreach ($user in $users)
{
    $targetuser=[adsi]("WinNT://" + $HostPC + "/$user, user")
    Write-Warning "Setting user [$($targetuser.name)] as password not expire."
    $userFlags = $targetuser.Get("UserFlags")
    $userFlags = $userFlags -bor 0x10000 # 0x10040 will "not expire + not change password"
    $targetuser.Put("UserFlags", $userFlags)
    $targetuser.SetInfo()
}
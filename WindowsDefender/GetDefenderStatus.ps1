$r = Get-MpComputerStatus
$p = $r | Get-Member -MemberType Properties
$p | where Name -match "enabled" | foreach {"$($_.Name): $($r.($_.Name))"}

<#
AMServiceEnabled: True
AntispywareEnabled: True
AntivirusEnabled: True
BehaviorMonitorEnabled: True
IoavProtectionEnabled: True
NISEnabled: True
OnAccessProtectionEnabled: True
RealTimeProtectionEnabled: True
#>
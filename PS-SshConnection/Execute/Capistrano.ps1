#Requires -Version 3.0

$deploy = "deploytask"
$deploygroup = "deploygroup"

$answer = Read-Host "Do you want to Deploy [ $deploy ] to [ $deploygroup ] (y/n)"

if ($answer -eq "y")
{
    Invoke-CapistranoDeploy `
        -deploygroup $deploygroup `
        -captask "deploy" `
        -deploypath CapistranoFullPath `
        -rsakey RSAKeyForSSH `
        -user SSHUser `
        -hostip IpAddress
}
elseif ($answer -ne "y" -and $answer -ne "n")
{
    Write-Warning 'Please input "y" or "n"'
}
else
{
    "Cancelled execution. press any key to exit."
    pause
    exit
}
Remove-Module PS-MySQLConnect
Import-Module PS-MySQLConnect

<#
#$HostAddress="host1"
#$HostAddress="host2"

$parameters = @{
User = "user"
Password = "passowrd"
Hostaddress="IPAddress or NetBIOS"
}

#Remove-MySQLTriggerCreatedModified @Parameters -Verbose
Remove-MySQLTriggerCreatedModified @Parameters

#>
$HostAddress = @(
    "host1"
    "host2"
    "host3"
    "host4"
    "host5"
    "host6"
    "host7"
)


$HostAddress `
    | %{
        $parameters = @{
        User = "user"
        Password = "passowrd"
        HostAddress=$_
        }
        $parameters} `
    | %{ Remove-MySQLTriggerCreatedModified @parameters }

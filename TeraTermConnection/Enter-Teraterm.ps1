#Requires -Version 3.0

[CmdletBinding(  
    SupportsShouldProcess = $false,
    ConfirmImpact = "none",
    DefaultParameterSetName = "PadRight"
)]
param(

    [Parameter(
    HelpMessage = "Input path of Terterm Pro execution file 'ttermpro.exe' exists",
    Position = 0
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $teraterm="C:\Program Files (x86)\teraterm\ttermpro.exe",

    [Parameter(
    HelpMessage = "Input Connecting Host IP/NetBIOS to connect",
    Position = 1
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $ip,

    [Parameter(
    HelpMessage = "Input Port number to connect",
    Position = 2
    )]
    [ValidateNotNullOrEmpty()]
    [int]
    $port="22",

	[Parameter(
    HelpMessage = "Input SSH type : default value = /ssh2",
    Position = 3
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $ssh="/ssh2",

    [Parameter(
    HelpMessage = "Input Authentication type : default value = publickey",
    Position = 4
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $auth="publickey",

    [Parameter(
    HelpMessage = "Input username to login : default value = ec2-user",
    Position = 5
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $user="ec2-user",

    [Parameter(
    HelpMessage = "Input rsa key path : default value = C:\Program Files (x86)\teraterm\RSA\purplehosts.pem",
    Position = 6
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $keyFile="C:\Program Files (x86)\teraterm\RSA\purplehosts.pem"

)

function Enter-Teraterm{
 
    [CmdletBinding(  
        SupportsShouldProcess = $false,
        ConfirmImpact = "none"
    )]
 
    param
    (
    [Parameter(
    HelpMessage = "Input path of Terterm Pro execution file 'ttermpro.exe' exists",
    Position = 0
    )]
    [ValidateScript({Test-Path $_})]
    [ValidateNotNullOrEmpty()]
    [string]
    $teraterm="C:\Program Files (x86)\teraterm\ttermpro.exe",

    [Parameter(
    HelpMessage = "Input Connecting Hot IP/NetBIOS to connect",
    Position = 1
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $ip,

    [Parameter(
    HelpMessage = "Input Port number to connect",
    Position = 2
    )]
    [ValidateNotNullOrEmpty()]
    [int]
    $port="22",

	[Parameter(
    HelpMessage = "Input SSH type : default value = /ssh2",
    Position = 3
    )]
    [ValidateSet("/ssh1","/ssh2")] 
    [ValidateNotNullOrEmpty()]
    [string]
    $ssh="/ssh2",

    [Parameter(
    HelpMessage = "Input Authentication type : default value = publickey",
    Position = 4
    )]
    [ValidateSet("password","publickey","challenge","pageant")] 
    [ValidateNotNullOrEmpty()]
    [string]
    $auth="publickey",

    [Parameter(
    HelpMessage = "Input username to login : default value = ec2-user",
    Position = 5
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $user="ec2-user",

    [Parameter(
    HelpMessage = "Input rsa key path : default value = C:\Program Files (x86)\teraterm\RSA\purplehosts.pem",
    Position = 6
    )]
    [ValidateScript({Test-Path $_})]
    [ValidateNotNullOrEmpty()]
    [string]
    $keyFile="C:\Program Files (x86)\teraterm\RSA\purplehosts.pem"
 
    )

    begin
    {
		try
		{
			$process = New-Object System.Diagnostics.Process
		}
		catch
		{
		}
		
		try
		{
			$process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo @($teraterm)
		}
		catch
		{
		}
    }

    process
    {
		try
		{
			[string]$connection = $ip + ":" + $port
		}
		catch
		{
		}
		
		$process.StartInfo.WorkingDirectory = (Get-Location).Path

		#"C:\Program Files (x86)\teraterm\ttermpro.exe" 192.168.0.100:22 /ssh2 /auth=publickey /user=user /keyfile=D:\key.rsa
		$process.StartInfo.Arguments = "$connection $ssh /auth=$auth /user=$user /keyfile=$keyFile"
		
		$process.Start() > $null
    }
 
}

<#
# Test Connection (Keyfile not allowed contain space)
$teraterm = "C:\Program Files (x86)\teraterm\ttermpro.exe"
$keyFile = "D:\Software\AWS\RSA\purplehosts.pem"
$ip = "192.168.100.1001"
$port = 22
$auth="publickey"
$user="ec2-user"
$ssh="/ssh2"


Enter-Teraterm -teraterm $teraterm -ip $ip -keyFile $keyFile
#>
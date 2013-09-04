# Requires -Version 3.0

function Test-Elevated
{
    <#
    .SYNOPSIS
        Retrieve elavated status of PowerShell Console.

    .DESCRIPTION
        Test-Elevated will check shell was elevated is required for some operations access to system folder, files and objects.
      
    .NOTES
        Author: guitarrapc
        Date:   June 17, 2013

    .OUTPUTS
        bool

    .EXAMPLE
        C:\PS> Test-Elevated

            true

    .EXAMPLE
        C:\PS> Test-Elevated

            false
        
    #>


	$user = [Security.Principal.WindowsIdentity]::GetCurrent()
	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

}

Write-Verbose "checking is this user elevated or not."
if(-not(Test-Elevated))
{
    $warningMessage = "To run this Cmdlet on UAC 'Windows Vista, 7, 8, Windows Server 2008, 2008 R2, 2012 and later versions of Windows' must start an elevated PowerShell console."
	Write-Warning $warningMessage
    Read-Host "Press any key."
    # exit を置けば終了するし てきとーに
}

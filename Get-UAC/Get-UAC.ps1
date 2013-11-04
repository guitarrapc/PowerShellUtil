function Get-UAC
{
<#
.Synopsis
   Check UAC configuration from Registry
.DESCRIPTION
   This cmdlet will return UAC is 'Enabled' or 'Disabled' or 'Unknown'
.EXAMPLE
   Get-UAC
.EXAMPLE
   Get-UAC -Verbose
#>

    [CmdletBinding()]
    Param
    (
    )

    begin
    {
        $path = "registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System"
        $name = "EnableLUA"
    }

    process
    {
        $uac = Get-ItemProperty $path
        if ($uac.$name -eq 1)
        { 
            Write-Verbose ("Registry path '{0}', name '{1}', value '{2}'" -f (Get-Item $path).name, $name, $uac.$name)
            "Enabled" 
        } 
        elseif ($uac.$name -eq 0) 
        { 
            Write-Verbose ("Registry path '{0}', name '{1}', value '{2}'" -f (Get-Item $path).name, $name, $uac.$name)
            "Disabled" 
        }
        else 
        {
            Write-Verbose ("Registry path '{0}', name '{1}', value '{2}'" -f (Get-Item $path).name, $name, $uac.$name)
            "Unknown"
        }
    }
}
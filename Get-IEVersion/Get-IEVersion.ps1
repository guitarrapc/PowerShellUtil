function Get-IEVersion
{
<#
.Synopsis
   Check IEVersion from Registry
.DESCRIPTION
   This cmdlet will return IEVersion
.EXAMPLE
    # if returned '9.11.9600.16384' then it will be IE11 '11.0.9600.16384'
   Get-IEVersion
.EXAMPLE
   Get-IEVersion -Verbose
#>

    [CmdletBinding()]
    Param
    (
    )

    begin
    {
        $path = "registry::HKLM\SOFTWARE\Microsoft\Internet Explorer"
        $name = "Version"
    }

    process
    {
        $uac = Get-ItemProperty $path
        if ($uac) 
        { 
            Write-Verbose ("Registry path '{0}', name '{1}', value '{2}'" -f (Get-Item $path).name, $name, $uac.$name)
            $uac.$name
        }
        else 
        {
            Write-Verbose ("Registry path '{0}', name '{1}', value '{2}'" -f (Get-Item $path).name, $name, $uac.$name)
            Write-Warning ("Could not found '{0}' from '{1}'" -f $name, (Get-Item $path).name)
        }
    }
}
$module = "PSWindowsUpdate"
$PSWindowsUpdate = @{}

foreach ( $name in (Get-Command -Module $module).Name)
{
     $cmdlet = $name.Replace("-","")
     $definition = $(Get-Command -module $module | where name -eq $name).Definition
     $PSWindowsUpdate.$cmdlet = [ScriptBlock]::Create($definition)
}

&$PSWindowsUpdate.GetWUList


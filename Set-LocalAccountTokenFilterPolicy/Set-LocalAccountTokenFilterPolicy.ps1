#Requires -Version 2.0

function Set-LocalAccountTokenFilterPolicy{

    [CmdletBinding()]
    param
    (
    )

    begin
    {
        $path = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        $key = "LocalAccountTokenFilterPolicy"
        $value = 1
    }

    process
    {
        if ((Get-ItemProperty -Path registry::$path -Name $key).$key -ne $value)
        {
            New-ItemProperty -Path registry::$path -Name $key -Value $value -Force
        }
        else
        {
            Write-Warning ("{0} already exist on {1} as {2}." -f $key, $path, $value)
            Get-ItemProperty -Path registry::$path -Name $key
        }
    }
}
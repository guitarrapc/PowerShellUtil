#Requires -Version 3.0

function Invoke-CommandSpecificCulture
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory,
            position = 0)]
        [System.Globalization.CultureInfo]
        $culture,

        [parameter(
            mandatory,
            position = 1)]
        [ScriptBlock]
        $ScriptBlock,

        [parameter(
            mandatory = 0,
            position = 2)]
        [string]
        $ComputerName,

        [parameter(
            mandatory = 0,
            position = 3)]
        [System.Management.Automation.PSCredential]
        $credential
    )

    begin
    {
        $ErrorActionPreference = "Stop"
    }

    process
    {
        try
        {
            $currentUICulture = [Threading.Thread]::CurrentThread.CurrentUICulture
            $currentCulture = [Threading.Thread]::CurrentThread.CurrentCulture
            $newUICulture = [System.Globalization.CultureInfo]::CreateSpecificCulture($culture)

            [Threading.Thread]::CurrentThread.CurrentCulture = $newUICulture
            [Threading.Thread]::CurrentThread.CurrentUICulture = $newUICulture

            if ($PSBoundParameters.ComputerName)
            {
                if ($PSBoundParameters.credential)
                {
                    Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $ComputerName -Credential $credential
                }
                else
                {
                    Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $ComputerName
                }
            }
            else
            {
                Invoke-Command -ScriptBlock $ScriptBlock
            }
        }
        catch
        {
            throw $_
        }
        finally
        {
            [Threading.Thread]::CurrentThread.CurrentUICulture = $currentUICulture
            [Threading.Thread]::CurrentThread.CurrentCulture = $currentCulture
        }
    }
}
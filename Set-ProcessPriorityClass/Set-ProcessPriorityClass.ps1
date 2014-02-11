function Set-ProcessPriorityClass
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory,
            position = 0,
            valueFromPipeline,
            valueFromPipelineByPropertyName)]
        [string[]]
        $Name,

        [parameter(
            mandatory = 0,
            position = 1,
            valueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Diagnostics.ProcessPriorityClass]
        $Priority,

        [parameter(
            mandatory = 0,
            position = 2)]
        [switch]
        $WhatIf
    )

    begin
    {
        DATA message
        {
            ConvertFrom-StringData `
            "
                PriorityNotChange  = Process Name '{0}' Priority '{1}' was already same as Priority '{2}' you set. Skip priority change.
                PriorityChange     = Process Name '{0}' changed Priority from '{1}' to '{2}'.
                ProcessNotFound    = Process Name '{0}' not found. Skip priority change.
            "
        }
    }

    process
    {
        foreach ($n in $Name)
        {
            try
            {
                # Get process
                $ps = Get-Process | where Name -eq $n

                # process exist check
                if ($null -ne $ps)
                {
                    # what if check
                    if ($PSBoundParameters.WhatIf.IsPresent)
                    {
                        $Host.UI.WriteLine(("What if: " + $message.PriorityChange -f $ps.Name, $ps.PriorityClass, $Priority))
                    }
                    else
                    {
                        # process priority check
                        if ($ps.PriorityClass -ne $Priority)
                        {
                            # execute
                            Write-Verbose ($message.PriorityChange -f $ps.Name, $ps.PriorityClass, $Priority)
                            $ps.PriorityClass = $Priority
                        }
                        else
                        {
                            # priority want to change was same as current.
                            Write-Verbose ($message.PriorityNotChange -f $ps.Name, $ps.PriorityClass, $Priority)
                        }
                    }
                }
                else
                {
                    # process missing
                    Write-Warning ($message.ProcessNotFound -f $n)
                }
            }
            finally
            {
                # dispose item
                if ($ps -ne $null){$ps.Dispose()}
            }
        }
    }
}


function Test-ProcessPriorityClass
{
    # Parameter Change
    Set-ProcessPriorityClass -Name "powershell" -Priority High -Verbose

    # Pipeline Change
    Get-Process | where Name -eq PowerShell | Set-ProcessPriorityClass -Priority Normal -Verbose

    # Splatting Change
    $param = @{
        Name = "powershell"
        Priority = "High"}
    Set-ProcessPriorityClass @param -Verbose

    # WhatIf
    Get-Process | where Name -eq PowerShell | Set-ProcessPriorityClass -Priority Normal -Verbose -WhatIf

}

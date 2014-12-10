function New-SelectMany 
{
<#
.EXAMPLE
SelectMany -Source (1,2),(3,4) {$Source | %{"OU={0}" -f $_}}
# OU=1
# OU=2
# OU=3
# OU=4

.EXAMPLE
SelectMany -Source (1,2),(3,4)
# 1
# 2
# 3
# 4
 
.EXAMPLE
SelectMany -Source (1,2),(3,4) | measure
# Count    : 4

.EXAMPLE
1,2,(3,4) | SelectMany -ScriptBlock {$Source | %{"OU={0}" -f $_}}
# OU=1
# OU=2
# OU=3
# OU=4
#>
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ValueFromPipeline = 1)]
        [PSObject[]]$Source,
 
        [parameter(Mandatory = 0, Position = 1)]
        [ScriptBlock]$ScriptBlock = {$Source}
    )
    
    process
    {
        foreach ($x in $Source)
        {
            $output = $ScriptBlock.GetNewClosure().InvokeWithContext(
                $null,
                (New-Object "System.Management.Automation.PSVariable" ("Source", $x))
            )
            foreach ($o in $output)
            {
                $o
            }
        }
    }
}
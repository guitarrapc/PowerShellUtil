#Requires -Version 3.0

function Get-StrictMode
{

    [CmdletBinding()]
    param(
        [switch]
        $showAllScopes
    )

    $currentScope = $executionContext `
    | Get-Field -name _context -valueOnly `
    | Get-Field -name _engineSessionState -valueOnly `
    | Get-Field -name currentScope -valueOnly `
    | Get-Field -name *Parent* -valueOnly `
    | Get-Field -name *Parent* -valueOnly
    
    $scope = 0
    while ($currentScope)
    {
        $strictModeVersion = $currentScope | Get-Field -name *StrictModeVersion* -valueOnly
        $currentScope = $currentScope | Get-Field -name *Parent* -valueOnly

        if ($showAllScopes)
        {
            New-Object PSObject -Property @{
                Scope             = $scope++
                StrictModeVersion = $strictModeVersion}
        }
        elseif ($strictModeVersion)
        {
            $strictModeVersion
        }
    }
}

function Get-Field
{
    [CmdletBinding()]
    param (
        [Parameter(
            mandatory = 0,
            Position  = 0)]
        [string[]]
        $name = "*",

        [Parameter(
            mandatory = 1,
            position  = 1,
            ValueFromPipeline = 1)]
        $inputObject,
            
        [switch]
        $valueOnly
    )
 
    process
    {
        $type = $inputObject.GetType()
        [string[]]$bindingFlags = ("Public", "NonPublic", "Instance")

        $type.GetFields($bindingFlags) `
        | where {
            foreach($currentName in $name)
            {
                if ($_.Name -like $currentName)
                { 
                    return $true
                }
            }} `
        | % {
            $currentField = $_
            $currentFieldValue = $type.InvokeMember(
                $currentField.Name,
                $bindingFlags + "GetField",
                $null,
                $inputObject,
                $null
            )
                
            if ($valueOnly)
            {
                $currentFieldValue
            }
            else
            {
                $returnProperties = @{}
                foreach ($prop in @("Name", "IsPublic", "IsPrivate"))
                {
                    $ReturnProperties.$prop = $CurrentField.$prop
                }

                $returnProperties.Value = $currentFieldValue
                New-Object PSObject -Property $returnProperties
            }
        } 
    }
}


# StrictMode is Null in initilal
Get-StrictMode

# Set Strict mode to check
Set-StrictMode -Version latest

# StrictMode will show as your PS Version
Get-StrictMode
<#
Major  Minor  Build  Revision
-----  -----  -----  --------
5      0      9701   0 
#>

# turn off strict mode
Set-StrictMode -Off
<#
Major  Minor  Build  Revision
-----  -----  -----  --------
0      0      -1     -1      
#>

# StrictMode will show as 0
Get-StrictMode
<#
Major  Minor  Build  Revision
-----  -----  -----  --------
0      0      -1     -1      
#>

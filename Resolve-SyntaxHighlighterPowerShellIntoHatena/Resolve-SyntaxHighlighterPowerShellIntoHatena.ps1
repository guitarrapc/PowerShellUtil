#Requires -Version 3.0

function Resolve-SyntaxHighlighterPowerShellIntoHatena
{
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Input PowerShell code to convert special character
        [Parameter(
            Mandatory,
            ValuefromPipeline,
            ValuefromPipelineByPropertyName,
            position = 0)]
        [string[]]
        $inputcode
    )

    Begin
    {
        $leftSquareBrackets = @("\[","&#91;")
        $rightSquareBrackets = @("\]","&#93;")
        $leftAngleBrackets = @("<","&lt;")
        $rightAngleBrackets = @(">","&gt;")
        $colon = @(":","&#58;")
    }

    Process
    {
        $inputcode `
            -replace $leftSquareBrackets `
            -replace $rightSquareBrackets `
            -replace $leftAngleBrackets `
            -replace $rightAngleBrackets `
            -replace $colon
    }
}

<#
#### Sample
$inputcode = @'
string[]$hoge
"<>"
http://tech.guitarrapc.com
'@

$inputcode | Resolve-SyntaxHighlighterPowerShellIntoHatena
#>
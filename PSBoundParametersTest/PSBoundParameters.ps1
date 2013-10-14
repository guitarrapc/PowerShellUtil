function hoge {
[CmdletBinding()]            
param(
)
    $PSBoundParameters.Verbose.IsPresent
}            


hoge -Verbose -Debug
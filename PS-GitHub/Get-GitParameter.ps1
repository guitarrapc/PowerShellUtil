#Requires -Version 3.0

function Get-GitParameter{
    param
    (
        [string]
        $parameter
    )

    Get-GitConfig | ? {$_ -match $parameter} | ConvertFrom-Csv -Delimiter "=" -Header "key","Value"
}
function Set-Ace{

    [CmdletBinding()]
    param(
    [parameter(
        position = 0,
        mandatory = 0
    )]
    [string]
    $path
    )

    if (Test-Path -Path $path)
    {
        start-process -FilePath takeown -ArgumentList "/F $path /A /R"
    }
    else
    {
        Write-Warning "File not exist. Please check path you tried."
    }

}
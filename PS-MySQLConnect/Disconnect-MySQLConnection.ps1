#Requires -Version 2.0

function Disconnect-MySQLConnection{

    param(
        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        $connection
    )
    
    begin
    {
        Write-Verbose "Loading $PSCommandPath ."
    }
    process
    {
        Write-Verbose "Disconnecting currenct mysql Connection."
        $connection.close()
        $connection.dispose()
    }
}

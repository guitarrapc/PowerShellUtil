#Requires -Version 2.0

function Invoke-MySQLNonQuery{
    Param(
        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        [string]
        $Query,

        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        $Connection
    )
       
    begin
    {
        Write-Verbose "Loading $PSCommandPath ."
    }
    process
    {
        Try 
        {
            Write-Verbose "Creating new object with passed 'Connection' and 'Query'."
            $Command = $connection.CreateCommand()

            Write-Verbose "Loading Query."
            $Command.CommandText = $query

            Write-Verbose "Executing Query."
            $Result = $Command.ExecuteNonQuery()

            Write-Verbose "Dispose Command."
            $Command.Dispose()
        }
        Catch 
        {
            Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
        }
    }
    end
    {
        if($Result)
        {
            Write-Verbose "Successfully return Result."
            return $Result
        }
        else
        {
            Write-Verbose "Returned false."
            return $false
        }
    }
}
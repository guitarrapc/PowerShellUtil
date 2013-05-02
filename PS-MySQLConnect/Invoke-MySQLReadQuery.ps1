#Requires -Version 2.0

function Invoke-MySQLReadQuery{
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
            $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
            $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)

            Write-Verbose "Creating new Dataset to Fill in returned table."
            $DataSet = New-Object System.Data.DataSet

            Write-Verbose "Filling returned data to dataset."
            $RecordCount = $DataAdapter.Fill($dataSet, "data")

            Write-Verbose "Command disposed."
            $Command.Dispose()

            Write-Verbose "Returing Table in Dataset to Result."
            $Result = $DataSet.Tables[0]
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
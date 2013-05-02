#Requires -Version 2.0

function Get-MySQLDatabases{
    Param(
        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        [string]
        $Query = "select TABLE_SCHEMA as SchemaName,TABLE_NAME as TableName from information_schema.`TABLES`;",

        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        $Connection,

        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        [string]
        $SchemaName

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
            $RecordCount = $dataAdapter.Fill($dataSet, "data")

            Write-Verbose "Command disposed."
            $Command.Dispose()

            Write-Verbose "Returing Table in Dataset to Result."
            $Result = $DataSet.Tables[0]
        }
        Catch 
        {
            Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
        }
        Finally 
        {
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

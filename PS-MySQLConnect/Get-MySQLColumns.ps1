#Requires -Version 2.0

function Get-MySQLColumns{
    Param(
        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        [string]
        $Query = "SELECT column_name AS COLUMNNAME, data_type AS DATATYPE, is_nullable AS IsNullable, column_default AS COLUMNDEFAULT, table_name AS TABLENAME, Table_schema AS SCHEMANAME, COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS",

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
        $SchemaName,

        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        [string]
        $Table
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
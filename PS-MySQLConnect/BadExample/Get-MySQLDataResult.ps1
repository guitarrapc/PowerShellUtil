#Requires -Version 2.0

function Get-MySQLDataResult{
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
        [string]
        $User,

        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        [string]
        $Password,

        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        [string]
        $HostAddress,

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
        Write-Verbose "Create Connection String"
        $ConnectionString = "server=" + $HostAddress + ";port=3306;uid=" + $User + ";pwd=" + $Password + ";database="+$SchemaName+""
    }
    process
    {
        Try 
        {
            Write-Verbose "Loading MySQL Connecter Assembly with partial name 'MySQL.Data' and open connection"
            [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")

            Write-Verbose "Creating new Connection."
            $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
            $Connection.ConnectionString = $ConnectionString
            $Connection.Open()

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
        catch [System.Management.Automation.PSArgumentException] 
        {
            Write-Host "Unable to connect to MySQL server, do you have the MySQL connector installed..?"
            $_
            exit
        }
        Catch 
        {
            Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
            $_.Exception.GetType().FullName
            $_.Exception.Message
            exit
        }
        Finally 
        {
            Write-Verbose "Close Connection loaded."
            $Connection.Close()
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
# Requires -Version 2.0

function Get-MySQLDataColumns{
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
        $Database,

        [Parameter(
        Mandatory = $false,
        ParameterSetName = '',
        ValueFromPipeLinebyPropertyName = '',
        ValueFromPipeline = $true)]
        [string]
        $Table,

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
        [ValidateSet(
            "TINYINT","SMALLINT","MEDIUMINT","INT","BIGINT","FLOAT","DOUBLE","BIT",
            "DATETIME","DATE","TIMESTAMP","TIME","YEAR",
            "CHAR","BINARY","TINYBLOB","BLOB","MEDIUMBLOB","LONGTEXT","TINYTEXT","TEXT","MEDIUMTEXT","LONGTEXT",
            "VARCHAR","VARBINARY",
            "ENUM","SET")] 
        [string]
        $DataType
    )


    begin
    {
        $Result = $null
        $ConnectionString = "server=" + $Host + ";port=3306;uid=" + $User + ";pwd=" + $Password + ";database="+$Database+""
    }
    process
    {
        Try 
        {
            [void][System.Reflection.Assembly]::LoadWithPartialName("MySQL.Data")
            $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
            $Connection.ConnectionString = $ConnectionString
            $Connection.Open()

            $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
            $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
            $DataSet = New-Object System.Data.DataSet
            $RecordCount = $dataAdapter.Fill($dataSet, "data")
            $Result = $DataSet.Tables[0]
        }
        Catch 
        {
            Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
        }
        Finally 
        {
            $Connection.Close()
        }


        $Column = $Result `
            | Get-Member `
            | where {($_.definition -match $DataType) -and ($_.MemberType -eq "Property")} `
            | ForEach-Object { 
                [PSCustomObject]@{
                ColumnName = $_.name 
                ColumnType = $_.Definition.split(" ")[0]}}

    }
    end
    {
        $Column
    }

}
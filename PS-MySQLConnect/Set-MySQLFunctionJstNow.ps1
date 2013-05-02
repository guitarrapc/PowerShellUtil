#Requires -Version 2.0

function Set-MySQLFunctionJstNow{
    
    Param(
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
        $HostAddress
    )

    begin
    {
        Write-Verbose "Loading $PSCommandPath ."
    }
    process
    {
        Write-Verbose "Creating Paramters for connection."
        $parameters = @{
        user = $User
        Password = $Password
        hostaddress = $HostAddress
        }

        Write-Verbose "Opening connection"
        $connection = New-MySQLConnection @parameters

        Write-Verbose "Load query to get Schema_Name from infomration_schema, and run query."
        $query = "SELECT TABLE_SCHEMA AS SCHEMANAME,TABLE_NAME AS TABLENAME, ENGINE, TABLE_COMMENT FROM INFORMATION_SCHEMA.`TABLES` WHERE TABLE_NAME LIKE '%_MASTERS';"
        $result = Get-MySQLDatabases -Query $query -Connection $connection

        Write-Verbose "Sort Schema and get unique."
        $schemas = $result.SchemaName | sort -Unique

        Write-Verbose "Define Function query for jst_now"
        $queryFunction = "
DROP FUNCTION IF EXISTS jst_now;
CREATE FUNCTION jst_now()
 	RETURNS datetime
  	DETERMINISTIC
  	NO SQL
  	SQL SECURITY Definer
  	COMMENT 'get jst time, ust+9:00'
BEGIN	
    return CONVERT_TZ(CURRENT_TIMESTAMP(),'+00:00','+09:00');
END"

        Write-Verbose "Start foreach schemas."
        foreach ($schema in $Schemas){

            Write-Host "Change Database to $schema " -ForegroundColor Green
            Invoke-MySQLReadQuery -Query "use $schema ;" -Connection $connection
            
            Write-Host "Executing create function query to $Schema" -ForegroundColor Green
            Invoke-MySQLNonQuery -Query $queryFunction -Connection $connection

            Write-Host "Executing show function status query." -ForegroundColor Green
            Invoke-MySQLReadQuery -Query "show function status;" -Connection $connection

            }
    }

    end
    {
        Disconnect-MySQLConnection -connection $connection
    }

}
#Requires -Version 2.0

function Remove-MySQLTriggerCreatedModified{
    
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
        $Query = "SELECT column_name AS COLUMNNAME, data_type AS DATATYPE, is_nullable AS IsNullable, column_default AS COLUMNDEFAULT, table_name AS TABLENAME, Table_schema AS SCHEMANAME, COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%_MASTERS'"
        $result = Get-MySQLColumns -Query $Query -Connection $connection | where datatype -eq "datetime"

        Write-Verbose "Sort Schema and get unique."
        $Schemas = $result | sort SchemaName -Unique
    
        Write-Verbose "Start foreach schemas."
        foreach ($schema in $Schemas){

            Write-Verbose "Change Database to $schema "
            Invoke-MySQLReadQuery -Query "use $($Schema.SchemaName) ;" -Connection $connection

            Write-Verbose "Load query to get Table_Name from infomration_schema, and run query."
            $Query = "SELECT column_name AS COLUMNNAME, data_type AS DATATYPE, is_nullable AS IsNullable, column_default AS COLUMNDEFAULT, table_name AS TABLENAME, Table_schema AS SCHEMANAME, COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%_MASTERS'"
            $result = Get-MySQLColumns -Query $Query -Connection $connection  | where datatype -eq "datetime"

            Write-Verbose "Sort Table and get unique."
            $Tables = $result | where { $_.schemaname -eq $schema.SchemaName} | sort TableName -Unique

            Write-Verbose "Start foreach tables."
            foreach ($table in $Tables)
            {

                Write-Verbose "Load query to get COLUMN_Name from infomration_schema, and run query."
                $Query = "SELECT column_name AS COLUMNNAME, data_type AS DATATYPE, is_nullable AS IsNullable, column_default AS COLUMNDEFAULT, table_name AS TABLENAME, Table_schema AS SCHEMANAME, COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%_MASTERS'"
                $result = Get-MySQLColumns -Query $Query -Connection $connection  | where datatype -eq "datetime"

                Write-Verbose "Obtain only current Table Name Columns."
                $Columns = $result | where { $_.schemaname -eq $schema.SchemaName} | where { $_.TableName -eq $table.TableName}

                Write-Verbose "where cruese for target column."
                $created = $Columns | where {$_.columnName -like "crea*"}
                $modified = $Columns | where {$_.columnName -like "mod*"}

                Write-Verbose "Define Tigger query for Insert and Update"
                $TriggerNameInsert = $table.TableName + "_insert_time"
                $TriggerNameUpdate = $table.TableName + "_update_time"

                $queryInsertTrigger = "DROP TRIGGER IF EXISTS $TriggerNameInsert;"

                $queryUpdateTrigger = "DROP TRIGGER IF EXISTS $TriggerNameUpdate;"
                
                Write-Host "Executing Remove Insert Trigger query for $($Schema.SchemaName).$($table.TableName).$($created.ColumnName) / $($modified.ColumnName)"  -ForegroundColor Green
                Invoke-MySQLNonQuery -Query $queryInsertTrigger -Connection $connection

                Write-Host "Executing Remove Update Trigger query for $($Schema.SchemaName).$($table.TableName).$($created.ColumnName) / $($modified.ColumnName)" -ForegroundColor Green
                Invoke-MySQLNonQuery -Query $queryUpdateTrigger -Connection $connection

            }

        }
    }
    end
    {
        Disconnect-MySQLConnection -connection $connection
    }

}

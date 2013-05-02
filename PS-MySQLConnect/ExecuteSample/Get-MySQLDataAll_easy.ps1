Import-Module PS-MySQLConnect

# 対象ホストの全カラムを取得し、カラム名がmod*である者のみ表示
#Get-MySQLDatabases -HostAddress "HostIP" -Database "hoge" `
#    | %{ Get-MySQLTables -Database $_.database} `
#    | %{ Get-MySQLColumns -Database $_.database -Table $_.table } `
#    | ? {$_.type -eq "datetime" -and $_.field -like "mod*"} `
#    | sort field


$parameters = @{
User = "user"
Password = "passowrd"
Hostaddress="IPAddress or NetBIOS"
}
$connection = New-MySQLConnection @parameters
$atabases = Get-MySQLDatabases -Query "SELECT TABLE_SCHEMA AS SCHEMANAME,TABLE_NAME AS TABLENAME, ENGINE, TABLE_COMMENT FROM INFORMATION_SCHEMA.`TABLES` WHERE TABLE_NAME LIKE '%_MASTERS';" -Connection $connection
$column = $databases | sort SCHEMANAME -Unique | select SCHEMANAME | where SchemaName -eq "hoge" | %{ Get-MySQLColumns -Query "SELECT column_name AS COLUMNNAME, data_type AS DATATYPE, is_nullable AS IsNullable, column_default AS COLUMNDEFAULT, table_name AS TABLENAME, Table_schema AS SCHEMANAME, COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '%_MASTERS'" -SchemaName $_ -Connection $connection} | where datatype -eq "datetime"

$column | %{$_.SCHEMANAME + "." + $_.TABLENAME + "." + $_.COLUMNNAME}

Get-MySQLDataResult -Query "INSERT INTO duty_key_masters VALUE (3,10030,'TEST',10030,null,null,null);" @parameters -SchemaName "hogehoge"


#Execute-MySQLNonQuery -Query $queryFunction -Connection $connection
Execute-MySQLReadQuery -Query "SELECT * FROM hoge where id = 5;" -Connection $connection
Execute-MySQLNonQuery -Query "DELETE FROM hoge WHERE id = 5;" -Connection $connection
Execute-MySQLReadQuery -Query "SELECT * FROM hoge where id = 5;" -Connection $connection
Disconnect-MySQLConnection -connection $connection

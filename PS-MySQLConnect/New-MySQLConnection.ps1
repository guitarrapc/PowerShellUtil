#Requires -Version 2.0

function New-MySQLConnection{
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
        $HostAddress,

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
        Write-Verbose "Create Connection String"
        $Result = $null
        $ConnectionString = "server=" + $HostAddress + ";port=3306;uid=" + $User + ";pwd=" + $Password + ";database="+$SchemaName+""
    }
    process
    {
        Try 
        {
            Write-Verbose "Loading MySQL Connecter Assembly with partial name 'MySQL.Data' and open connection"
            [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
            $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection

            Write-Verbose "set Connection strings."
            $Connection.ConnectionString = $ConnectionString

            Write-Verbose "Opening new connection."
            $Connection.Open()
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
        }


    }
    end
    {
        Write-Verbose "Connection Successfuly created."
        return $Connection
    }

}

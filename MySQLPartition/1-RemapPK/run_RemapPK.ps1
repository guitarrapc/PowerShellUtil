param(
    [parameter(Mandatory=$true)]
    [string]$table,
    [parameter(Mandatory=$true)]
    [string[]]$key
)

function Get-RemapPKsql{

    [CmdletBinding()]
    param(
    [parameter(Mandatory=$true)]
    [string]$table,
    [parameter(Mandatory=$true)]
    [string[]]$key
    )

    begin
    {
    }

    process
    {
      
        $output = "ALTER TABLE "
        $output += $table
        $output += " DROP PRIMARY KEY `n"


        $output += ", ADD PRIMARY KEY "
        $output += "("
        
        $output += $key | %{$_ + " ,"}
        $beforeLast = $output.Length -1
        $output = $output.Substring(0,$beforeLast)
        
        $output += ");"
    }

    end
    {
        $output
    }
}



Get-RemapPKsql -table $table -key $key `
    | Out-File -FilePath .\RemapPKSQL_$table.sql -Encoding default
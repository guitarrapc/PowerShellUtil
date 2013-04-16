param(
    [parameter(Mandatory=$true)]
    [string]$table,
    [parameter(Mandatory=$true)]
    [string]$keyName,
    [parameter(Mandatory=$true)]
    [string[]]$key
)

function Get-NewDropUniqueKeysql{

    [CmdletBinding()]
    param(
    [parameter(Mandatory=$true)]
    [string]$table,
    [parameter(Mandatory=$true)]
    [string]$keyName,
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

        $output += " ADD UNIQUE "
        $output += ("'" + $keyName +"_2'")
        $output += "("
        
        $output += $key | %{$_ + " ,"}
        $beforeLast = $output.Length -1
        $output = $output.Substring(0,$beforeLast)
        
        $output += "); `n"


        $output += "ALTER TABLE "
        $output += $table

        $output += " DROP INDEX "
        $output += $keyName
        
        $output += "; `n"
    }

    end
    {
        $output
    }
}



Get-NewDropUniqueKeysql -table $table -keyName $keyName -key $key `
    | Out-File -FilePath .\NewDropUniqueKeySQL_$table.sql -Encoding default
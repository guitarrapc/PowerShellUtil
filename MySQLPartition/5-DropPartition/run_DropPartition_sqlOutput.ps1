param(
    [parameter(Mandatory=$true)]
    [string]$table,
    [parameter(Mandatory=$true)]
    [string]$column,
    [parameter(Mandatory=$true)]
    [int[]]$daysAdd
)

function Get-PartitionSQLbyWeekday{

    [CmdletBinding()]
    param(
    [parameter(Mandatory=$true)]
    [string]$table,
    [parameter(Mandatory=$true)]
    [string]$column,
    [parameter(Mandatory=$true)]
    [int[]]$daysAdd
    )

    begin
    {
    }

    process
    {
      
        $output = @"
ALTER TABLE $table 
    DROP PARTITION `n
"@
  
        $output += $daysAdd `
            | %{$(Get-Date).AddDays($_)} `
            | %{"`t`t p{0}{1:d2}{2:d2},`n" -f $_.Year,$_.Month,$_.Day,$_.AddDays("-1").Day}

        $beforeLast = $output.Length -2
        $output = $output.Substring(0,$beforeLast)
        $output += "`n"
        $output += "; "
    }

    end
    {
        $output
    }
}



Get-PartitionSQLbyWeekday -table $table -column $column -daysAdd $daysAdd `
    | Out-File -FilePath .\DropPartitionSQL_$table.sql -Encoding default
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
    ADD PARTITION( `n
"@
  
        $output += $daysAdd `
            | %{$(Get-Date).AddDays($_)} `
            | %{"`t`t PARTITION p{3}{4:d2}{5:d2} VALUES LESS THAN (TO_DAYS('{0}-{1:d2}-{2:d2} 00:00:00')) COMMENT = '{3}-{4:d2}-{5:d2}',`n" `
                -f  $_.Year,
                    $_.Month,
                    $_.Day,
                    $_.AddDays("-1").Year,
                    $_.AddDays("-1").Month,
                    $_.AddDays("-1").Day}

        $beforeLast = $output.Length -2
        $output = $output.Substring(0,$beforeLast)
        $output += "`n"
        $output += "); "
    }

    end
    {
        $output
    }
}



Get-PartitionSQLbyWeekday -table $table -column $column -daysAdd $daysAdd `
    | Out-File -FilePath .\AddPartitionSQL_$table.sql -Encoding default
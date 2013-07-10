function New-IpStringArray{

    param(
        [string]
        $base = "10.0.0",
        [string[]]
        $lastip
    )

    "$($lastip | %{$count=1}{
        if($count % 5 -eq 0)
        {
            "'$base.{0}'" -f $_ + ",`n"
        }
        else
        {
            "'$base.{0}'" -f $_ + ","
        }
        ++$count
    })" -replace " ","" -replace ",",", " -replace "'","`""

}

# Creates New IP String Array for C#
New-IpStringArray -base "10.0.0" -lastip (10..49)
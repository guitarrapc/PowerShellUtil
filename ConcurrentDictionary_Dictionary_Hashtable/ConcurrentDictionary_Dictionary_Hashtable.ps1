# Define
    $numitems = 1..64
    $initial = 101
    $processor = [System.Environment]::ProcessorCount
    $concurrencyLevel = $processor * 2


# Concurrent Dictionary
    $cd = New-Object "System.Collections.Concurrent.ConcurrentDictionary``2[int,int]($concurrencyLevel,$initial)"

    # try add
    foreach ($n in $numitems)
    {
        $cd.TryAdd($n,$n*$n)
    }

    # Try update if key for 1 was value 1.
    $cd.TryUpdate(1,10,1)



# Dictionary
    $dic = New-Object "System.Collections.Generic.Dictionary``2[int,int]"

    # Add will fail if there are same key
    foreach ($n in $numitems)
    {
        $dic.Add($n,$n*$n)
    }

    $dic


# hashtable
    $hash = @{}

    # Add will fail if there are same key
    foreach ($n in $numitems)
    {
        $hash.Add($n,$n*$n)
    }

    $hash
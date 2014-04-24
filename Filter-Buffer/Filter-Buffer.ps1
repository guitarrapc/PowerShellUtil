filter Get-Buffer
{
    param
    (
        [int]
        $Count,

        [type]
        $Type
    )

    begin
    {
        $initial = $Count
        $i = 1
        $buffer = New-Object "System.Collections.Generic.List[$type]"
        $result = New-Object "System.Collections.Generic.List[System.Collections.Generic.IList[$type]]"
    }

    process
    {
        $i++
        if ($i -le $Count)
        {
            # add
            $buffer.Add($_)
        }
        else
        {
            # add
            $buffer.Add($_)

            # move next
            $Count = $Count + $initial

            # add to contrainer
            $result.Add($buffer.ToArray())

            #clear current
            $buffer.Clear()
        }
    }

    end
    {
        # add to contrainer
        $result.Add($buffer.ToArray())

        # return
        return $result
    }
}

$return = 1..100 | Get-Buffer -Count 30 -type int
foreach ($x in $return)
{
    $x | measure | select -ExpandProperty count
<#
    Count    : 30
    Count    : 30
    Count    : 30
    Count    : 10
#>
    "$x"
#  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
# 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
# 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90
# 91 92 93 94 95 96 97 98 99 100
}

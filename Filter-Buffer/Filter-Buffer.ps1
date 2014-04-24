filter Get-Buffer
{
    param
    (
        [int]
        $Size,

        [type]
        $Type
    )

    begin
    {
        $initial = $Size
        $i = 1
        $list = New-Object "System.Collections.Generic.List[$type]"
        $listContainer = New-Object "System.Collections.Generic.List[System.Collections.Generic.List[$type]]"
    }

    process
    {
        $i++
        if ($i -le $Size)
        {
            # add
            $list.Add($_)
        }
        else
        {
            # add
            $list.Add($_)

            # move next
            $Size = $Size + $initial

            # add to contrainer
            $listContainer.Add($list.ToArray())

            #clear current
            $list.Clear()
        }
    }

    end
    {
        # add to contrainer
        $listContainer.Add($list.ToArray())

        # return
        return $listContainer
    }
}

$buffer = 1..100 | Get-Buffer -Size 30 -type int
foreach ($b in $buffer)
{
    $b | measure | select -ExpandProperty count
<#
    Count    : 30
    Count    : 30
    Count    : 30
    Count    : 10
#>
    "$b"
#  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
# 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
# 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90
# 91 92 93 94 95 96 97 98 99 100
}

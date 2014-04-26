# うごかないんじゃ！
function Get-BufferYeildReturn
{
    param
    (
        [object]
        $source,

        [int]
        $Count,

        [type]
        $Type
    )

    begin
    {
        $buffer = New-Object "$type[]" $count
        $index = 0
    }

    process
    {
        foreach ($x in $source)
        {
            $buffer[$index++] = $x
            if ($index -eq $count)
            {
                $buffer　#yield return したいじゃん？
                $index = 0
                $buffer = New-Object "$type[]" $count
            }

            if ($index -ne 0)
            {
                $dest = New-Object "$type[]" $index
                [Array]::Copy($buffer, $dest, $index)
                $dest #yield return したいじゃん？
            }
        }
    }
}

$hoge = Get-BufferYeildReturn -Count 3 -type int -source (1..10)
$hoge

<#
1
1
2
1
2
3
4
4
5
4
5
6
7
7
8
7
8
9
10
#>
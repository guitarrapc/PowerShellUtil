# うごかないんじゃ！
function Get-BufferPHP
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
        $result = New-Object "$type[]" $count
        $index = 0
        $bufferCount = 0
    }

    process
    {
        foreach ($x in $source)
        {
            $result[$index++] = $x
            if (++$bufferCount -eq $Count)
            {
                ++$index
                $bufferCount = 0
            }
        }
        $result
    }
}

$hoge = Get-BufferPHP -Count 3 -type int -source (1..10)
$hoge
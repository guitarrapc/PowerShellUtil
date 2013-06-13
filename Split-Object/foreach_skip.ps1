$Items = ps
$GroupNum = 20
[ScriptBlock]$ScriptBlock = {(get-date).DateTime}

$i=0
$hoge = foreach($item in $items)
{
    $item; if($i % $GroupNum -eq 0){&$ScriptBlock};++$i
}
$hoge | format-table -AutoSize
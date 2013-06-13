$Items = ps
$GroupNum = 20
[ScriptBlock]$ScriptBlock = {(get-date).DateTime}
    $Items | %{$i=1}{$_; if($i % $GroupNum -eq 0){&$ScriptBlock};++$i}

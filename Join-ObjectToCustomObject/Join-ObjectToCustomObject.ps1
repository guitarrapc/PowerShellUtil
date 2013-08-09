$ip = @(1,2,3,4,5,6)
$val = @("a","b","c","d","e","f")

$array = New-Object "object[,]" ($ip.Length+1),($val.Length+1)

0..$($ip.Length - 1) | %{$count=1}{
    
    $array[$count,$_] = $ip[$_]
    $array[$_,$count] = $val[$_]
    $count++
}

$result = $array | %{
    $count00 = 0
    $count01 = 1
    }{

    if ($count01 -le $ip.Length)
    {
        [PSCustomObject]@{
            ip = $array[$count00,$count01]
            val = $array[$count01,$count00]
        }
    
        $count00++
        $count01++
    }

}

$result
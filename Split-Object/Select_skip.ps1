$numbers = 1..131
$GroupNum = 20
$skipcount = [math]::Truncate($numbers.count / $GroupNum)

0..$skipcount | %{
    $numbers | Select-Object -skip $($GroupNum*$_) -First $GroupNum
	"--------------------------------------------"
}



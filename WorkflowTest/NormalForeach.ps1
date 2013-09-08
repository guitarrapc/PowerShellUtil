foreach ($pc in @("10.0.3.100","10.0.3.150"))
{
    Test-Connection -ComputerName $pc
}
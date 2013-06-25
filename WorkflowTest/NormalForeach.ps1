Measure-Command{
    foreach ($C in @("10.0.4.100","10.0.4.101"))
    {
        Test-Connection -ComputerName 127.0.0.1
    }
}
workflow testforeach{

    param(
    $computerName
    )

    foreach ($C in $PSComputerName)
    {
        Test-Connection -ComputerName 127.0.0.1
    }

}

Measure-Command{
    #@("10.0.4.100","10.0.4.101") | testforeach -PSComputerName $_
testforeach -pscomputerName @("10.0.4.100","10.0.4.101")
}
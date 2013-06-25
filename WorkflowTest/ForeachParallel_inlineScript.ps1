workflow testforeach{

    param(
    $computerName
    )

    foreach -parallel ($C in $PSComputerName)
    {
        InlineScript { Start-Process calc}
    }

}

Measure-Command{

    #@("10.0.4.100","10.0.4.101") | testforeach -PSComputerName $_
testforeach -pscomputerName @("10.0.4.100","10.0.4.101")

}

testforeach -pscomputerName @("10.0.4.100","10.0.4.101")

workflow test-workflowforeachparallel{

    param(
    $computerName
    )

    foreach -parallel ($pc in $computerName)
    {
        Test-Connection -ComputerName $pc
    }

}

test-workflowforeachparallel -computerName ("10.0.3.100","10.0.3.150")

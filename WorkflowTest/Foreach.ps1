workflow test-workflowforeach{

    param(
    $computerName
    )

    foreach ($pc in $computerName)
    {
        Test-Connection -ComputerName $pc
    }

}

test-workflowforeach -computerName ("10.0.3.100","10.0.3.150")
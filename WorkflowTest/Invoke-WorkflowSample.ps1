workflow Invoke-WorkflowParallel{

    [CmdletBinding(DefaultParameterSetName = "ScriptBlock")]
    param(
        [parameter(
            Mandatory = 1,
            Position = 0,
            ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $scriptBlock,
        
        [parameter(
            Mandatory = 1,
            Position = 0,
            ParameterSetName = "Expression")]
        [string]
        $expression,
        
        [parameter(
            Mandatory = 1,
            Position = 1)]
        [array]
        $array
    )

    if ($scriptBlock)
    {
        foreach -Parallel ($a in $array)
        {
            inlinescript
            {
                #$WorkflowScript = [ScriptBlock]::Create($using:ScriptBlock)
                #Invoke-Command -ScriptBlock {&$WorkflowScript} -ErrorAction Stop
                Invoke-RestMethod -Method Get -Uri google.com
            }
        }
    }
    elseif ($expression)
    {
        foreach -Parallel ($a in $array)
        {
            inlinescript
            {
                Invoke-Expression -Command $using:expression
            }
        }
    }
}

#Invoke-WorkflowParallel -scriptBlock {Invoke-RestMethod -Method Get -Uri google.com} -array 1,2,3,4,5
#Invoke-WorkflowParallel -expression "Invoke-RestMethod -Method Get -Uri google.com" -array 1,2,3,4,5
Invoke-WorkflowParallel -scriptBlock {Invoke-RestMethod -Method Get -Uri google.com} -array 1,2,3,4,5
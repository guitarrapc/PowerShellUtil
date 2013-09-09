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
            Position = 0,
            ParameterSetName = "other")]
        [string]
        $argumentlist,
        
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
                # これはだめ
                # Invoke-Command -ScriptBlock {&$usingScriptBlock}
                # これもだめ
                # Invoke-Command -ScriptBlock {$usingScriptBlock}
                # これもだめ
                # Invoke-Command -ScriptBlock $usingScriptBlock

                # ScriptBlock は生成してから行う
                $WorkflowScript = [ScriptBlock]::Create($using:ScriptBlock)
                Invoke-Command -ScriptBlock {&$WorkflowScript} -ErrorAction Stop
            }
        }
    }
    elseif ($expression)
    {
        foreach -Parallel ($a in $array)
        {
            inlinescript
            {
                # Invoke-Command とことなり生成が不要
                Invoke-Expression -Command $using:expression
            }
        }
    }
    elseif ($argumentlist)
    {
        # ScriptBlock でも Expression でもなく直接 PowerShell cmdlet を利用することは可能
        Write-Verbose -message "$argumentlist"
        Invoke-RestMethod -Method Get -Uri google.com
    }
}

# ScriptBlock で実行する場合
Invoke-WorkflowParallel -scriptBlock {Invoke-RestMethod -Method Get -Uri google.com} -array 1,2,3,4,5

# Expression で実行する場合
Invoke-WorkflowParallel -expression "Invoke-RestMethod -Method Get -Uri google.com" -array 1,2,3,4,5

# 直接 workflow に記述してある内容を実行する
Invoke-WorkflowParallel -argumentlist　"直接Workflow内部に記述した内容を実行する" -array 1,2,3,4,5 -Verbose
workflow test-workflowforeachparallelInlineScript{

    param(
    $computerName
    )

    foreach -parallel ($pc in $computerName)
    {
        # InlineScript を付けると Invoke-Command や Invoke-Expression など 通常の PowerShell Cmdletの多くが利用できるようになる
        InlineScript
        {
            # InlineScript内で、InlineScript 外の変数を取得する場合は using: 構文を用いる (ScriptBlock と同様)
            Test-Connection $using:pc
        }
    }

}

# Connection テスト
test-workflowforeachparallelInlineScript -computerName @("10.0.3.100","10.0.3.150")

# 通常の foreach の場合
# TotalSeconds      : 6.1301668 sec
Measure-Command {
    @("10.0.3.100","10.0.3.150") | %{Test-Connection $_}
}

# foreach -parallel の場合
# TotalSeconds      : 3.1872539 sec
Measure-Command {
    test-workflowforeachparallelInlineScript -computerName @("10.0.3.100","10.0.3.150")
}

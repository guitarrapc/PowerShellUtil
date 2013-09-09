workflow test-workflowOmitParameterName{

    # パラメータ名が省略されているので workflow として登録できない。
    Write-Warning "hoge"
}

workflow test-workflowOmitParameterNameCorrect{

    # パラメータ名をきっちり宣言すれば問題ない
    Write-Warning -message "hoge"
}

test-workflowOmitParameterNameCorrect
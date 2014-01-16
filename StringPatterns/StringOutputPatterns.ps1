# ```"```と```'```による単純な出力

##### 1. " で括る
"Hello World!"

##### 2. "で括ると変数は展開される(Hello World! と出力される)
$hoge = "Hello World!"
"$hoge"

##### 3. ' で括る
'Hello World!'

##### 4. 'で括ると変数は展開されない($fuga と出力される)
$fuga = "Hello World!"
'$fuga'

# Write-* Cmdlet による単純な出力

##### 5. Write-Output Cmdletで出力する
Write-Output -InputObject "Hello World!"
Write-Output "Hello World!"
Write-Output "Hello World!" | % {$_ + "hogehoge."}
Write-Output "Hello World!" | Out-File .\helloWorld.txt


##### 6. Write-Host Cmdletでホスト画面へのみ出力する
Write-Host -Object "Hello World!"
Write-Host "Hello World!"
Write-Host "Hello World!" -NoNewline
Write-Host "Hello World!" -ForegroundColor Magenta

##### 7. Write-Warning Cmdlet で警告をホスト画面へのみ出力する
Write-Warning -Message "Hello World!"

##### 8. Write-Verbose Cmdlet でVerbose時にのみホスト画面へ出力する
Write-Verbose -Message "Hello World!"
Write-Verbose -Message "Hello World!" -Verbose

$orgVerbosePreference = $VerbosePreference   # 現在のPreferenceを格納
$VerbosePreference = "Continue"              # Continue に変更して、必ず Verbose出力されるようにする
Write-Verbose -Message "Hello World! 1"      # 出力される
$VerbosePreference = $orgVerbosePreference   # 元の SilentryContinueに戻す
Write-Verbose -Message "Hello World! 2"      # 出力されない

##### 9. Write-Debug Cmdlet でデバッグ停止しつつ停止メッセージをホスト画面へのみ出力する
Write-Debug -Message "Hello World!" -Debug

$orgDebugPreference = $DebugPreference     # 現在のPreferenceを格納
$DebugPreference = "Continue"              # Continue に変更して、必ず Verbose出力されるようにする
Write-Debug -Message "Hello World! 1"      # Debug実行される
$DebugPreference = $orgDebugPreference     # 元の SilentryContinueに戻す
Write-Debug -Message "Hello World! 2"      # Debug実行されない

function hoge
{
    [CmdletBinding()]
    param()

    "Debug まえ"
    Write-Debug -Message "Hello World!"
    "Debug あと"
}
hoge -Debug

##### 10. Write-Error Cmdlet でエラーメッセージをホスト画面へのみ出力する
Write-Error -Message "Hello World!"

try
{
    $orgErrorActionPreference = $ErrorActionPreference  # 現在のPreferenceを格納
    $ErrorActionPreference = "Stop"                     # Stop に変更して、必ず Catch に捕捉されるようにする
    Write-Error -Message "Hello World! 1"               # Catchに補足実行される
    Write-Error -Message "Hello World! 2"               # 実行されない    
}
catch
{
    "捕捉"
}
finally
{
    $ErrorActionPreference = $orgErrorActionPreference  # 元の SilentryContinueに戻す
}


# $Host.UI による単純な出力

##### 11. $Host.UI.WriteLine()
$Host.UI.WriteLine("Hello World!")

##### 12. $Host.UI.WriteWarningLine()
$Host.UI.WriteWarningLine("Hello World!")

##### 13. $Host.UI.WriteVerboseLine()
$Host.UI.WriteVerboseLine("Hello World!")

##### 14. $Host.UI.WriteDebugLine()
$Host.UI.WriteDebugLine("Hello World!")

##### 15. $Host.UI.WriteErrorLine()
$Host.UI.WriteErrorLine("Hello World!")


# .NET Framework による単純な出力

##### 16. [System.Console]::WriteLine()
[System.Console]::WriteLine("Hello World!")

##### 17. [System.Console]::Write()
[System.Console]::Write("Hello World!")


# ヒアストリングによる単純な出力

##### 18. @" によるヒアストリング

$hoge = "Hello World!"
@"
全部ストリング
だよー
変数展開するのー
$hoge
"@

##### 19. @' によるヒアストリング

$fuga = "Hello World!"
@'
全部ストリング
だよー
変数展開しないのー
$fuga
'@

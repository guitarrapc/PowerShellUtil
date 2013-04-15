#Requires -Version 3.0

# PowerShell V3.0 (Windows 8移行)からLinuxの-tailに該当する実行が可能です。
# 例: 10行ずつ同一ディレクトリのtest.logを読む場合。

Get-Content .\test.log -Wait -Tail 10
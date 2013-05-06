@echo off

echo 管理者で実行すること！！ (ExecutionPolicy - 権限ののエラーが出ます)


powershell.exe -ExecutionPolicy RemoteSigned -File .\Get-ColumnCommentSQL.ps1 

pause
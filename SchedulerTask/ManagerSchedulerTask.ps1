# cim session も可能
$cred = Get-Credential -UserName administrator -Message "hoge"
$cim = New-CimSession -Credential $cred

# user / Pass の場合
$user = "hoge"
$pass = "fuga"

# action / trigger / settings の登録
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command 'Get-Date | Out-File D:\Test.log -Encoding default'"
$trigger = New-ScheduledTaskTrigger -DaysInterval 1 -Daily -At "20:15 PM"
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -Hidden

# cim sessionの場合 (Register との選択)
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -Hidden -CimSession $cim 

# 設定の登録
Register-ScheduledTask -TaskPath \ -TaskName test -Action $action -Trigger $trigger -Settings $settings

# cim sesionの場合 ( SettingSet との選択)
Register-ScheduledTask -TaskPath \ -TaskName test -Action $action -Trigger $trigger -Settings $settings -Force -CimSession $cim


# -Force Swtich で上書き可能 (付けないと 同名エラー)
Register-ScheduledTask -TaskPath \ -TaskName test -Action $action -Trigger $trigger -User $user -Password $pass
Register-ScheduledTask -TaskPath \ -TaskName test -Action $action -Trigger $trigger -Settings $settings -User $user -Password $pass -Force
Register-ScheduledTask -TaskPath \ -TaskName test -Action $action -Trigger $trigger -Settings $settings -Force

# 設定の取得
Get-ScheduledTask -TaskName test -TaskPath \

# 開始 / 停止
Start-ScheduledTask -TaskPath \ -TaskName test
Stop-ScheduledTask -TaskPath \ -TaskName test

# 無効 / 有効
Disable-ScheduledTask -TaskPath \ -TaskName test
Enable-ScheduledTask -TaskPath \ -TaskName test

# 設定の除去 (-AsJob Switch で確認なしで除去)
Unregister-ScheduledTask -TaskName test
Unregister-ScheduledTask -TaskName test -AsJob

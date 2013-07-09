# 自身のD:\Documentを hoge として共有してみます。
New-SmbShare –Name hoge –Path D:\Document\

# testというユーザーにfull accessを与えたい？はい。
New-SmbShare –Name hoge –Path D:\Document\ -FullAccess test

# testというユーザーにfull accessを与えたい？
New-SmbShare –Name hoge –Path D:\Document\ -FullAccess test

# これではtestしかアクセスできません。 他のユーザーにも与えるならどうぞ
New-SmbShare –Name hoge –Path D:\Document\ -FullAccess test,hogehoge@outlook.com

# Readアクセスだけ与えるのも簡単ですね。
New-SmbShare –Name hoge –Path D:\Document\ -FullAccess test -ReadAccess hogehoge@outlook.com


# SMBShareの取得
Get-SmbShare | ft -AutoSize


# SMBShareの削除 (Confirm付き)
Remove-SmbShare -Name hoge

# SMBShareの削除 (Confirmぬき)
Remove-SmbShare -Name hoge -Force

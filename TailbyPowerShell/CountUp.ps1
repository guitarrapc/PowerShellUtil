# もう片方では、以下の出力をしてみます。
#1..100 | %{1..100 | %{$_ | Out-File ./test.log -Append}}

1..100 | %{Get-Process | Out-File ./test.log -Append; sleep 5}
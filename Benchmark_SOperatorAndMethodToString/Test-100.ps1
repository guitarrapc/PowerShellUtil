$max = 100

# += Operator

Write-Host "String += Operator 1..$max test" -ForegroundColor Cyan
1..100 | %{Get-StringForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "Array += Operator 1..$max test" -ForegroundColor Cyan
1..100 | %{Get-ArrayForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "ArrayList += Operator 1..$max test" -ForegroundColor Cyan
1..100 | %{Get-ArrayListForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "List += Operator 1..$max test" -ForegroundColor Cyan
1..100 | %{Get-ListForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average


# Method
Write-Host "ArrayList Add Method 1..$max test" -ForegroundColor Green
1..100 | %{Get-ArrayListAddForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "List Add Method 1..$max test" -ForegroundColor Green
1..100 | %{Get-ListAddForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "StringBuilder Append Method 1..$max test" -ForegroundColor Green
1..100 | %{Get-StringBuilderForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average



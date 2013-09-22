$max = 20000

# += Operator

Write-Host "String += Operator 1..$max test" -ForegroundColor Cyan
Get-StringForeachTest -int (1..$max) | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "Array += Operator 1..$max test" -ForegroundColor Cyan
Get-ArrayForeachTest -int (1..$max) | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "ArrayList += Operator 1..$max test" -ForegroundColor Cyan
Get-ArrayListForeachTest -int (1..$max) | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "List += Operator 1..$max test" -ForegroundColor Cyan
Get-ListForeachTest -int (1..$max) | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average


# Method
Write-Host "ArrayList Add Method 1..$max test" -ForegroundColor Green
1..10 | %{Get-ArrayListAddForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "List Add Method 1..$max test" -ForegroundColor Green
1..10 | %{Get-ListAddForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average

Write-Host "StringBuilder Append Method 1..$max test" -ForegroundColor Green
1..10 | %{Get-StringBuilderForeachTest -int (1..$max)} | Measure-Object -Property TotalMilliseconds -Average | select -ExpandProperty Average



# Requires -Version 3.0
$path = Get-ChildItem -Path c:\
$path.fullName


$property = "Name"
$path.$property

$property = "fullname"
$path.$property

$propaies = $path | Get-Member -MemberType Properties | select -ExpandProperty Name

foreach ($p in $propaies)
{
    Write-Host $p -ForegroundColor Cyan
    $path.$p | Format-Table -AutoSize
    ""
}
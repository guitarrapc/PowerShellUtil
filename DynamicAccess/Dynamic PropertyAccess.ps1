# Requires -Version 3.0
$path = Get-ChildItem -Path c:\
$path.fullName


$property = "Name"
$path.$property

$property = "fullname"
$path.$property

$propaties = $path | Get-Member -MemberType Properties | select -ExpandProperty Name

foreach ($p in $propaies)
{
    Write-Host $p -ForegroundColor Cyan
    $path.$p | Format-Table -AutoSize
    ""
}

$Users = [PSCustomObject]@{
    hoge="hoge"
    fuga="fuga"
    foo="foo"
}

$prop = $Users | Get-Member -MemberType Properties

foreach ($p in $prop)
{
    $PSModulePath = "C:\Users\$($Users.$p)\Documents\WindowsPowerShell\Modules"
    if (-not(Test-Path $PSModulePath))
    {
        Write-Verbose "Create Module path"
        New-Item -Path $PSModulePath -ItemType Directory -Force
    }
    else
    {
        Write-Verbose " $PSModulePath already exist. Nothing had changed. `n"
    }
}
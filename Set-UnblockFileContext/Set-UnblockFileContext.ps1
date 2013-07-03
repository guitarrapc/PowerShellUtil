# Unblock Sample
<#
$path = "C:\hoge.pptx"
if (Test-Path -path $path)
{
    Unblock-File -Path C:\hoge.pptx 
}
#>

# Function to add Unblock context
function Set-UnblockFileContext{
    $key = "Registry::HKEY_CLASSES_ROOT\*\shell"
    $Command = "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe Unblock-File  -LiteralPath '%L'"

    if (-not(Test-Path -LiteralPath "$key\powershell" ))
    {
        cd -LiteralPath $key
        New-Item -Name "PowerShell" `
            | Set-ItemProperty -Name "(default)" -Value "Unblock Files" -PassThru

        cd PowerShell
        New-Item -Name "Command" `
            | Set-ItemProperty -Name "(default)" -Value $Command
    }
}

Set-UnblockFileContext
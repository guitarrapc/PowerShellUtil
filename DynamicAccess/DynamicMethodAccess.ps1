# Requires -Version 4.0
$fso = New-Object -ComObject Scripting.FileSystemObject
$method = "GetFolder"
$fso.$method("C:\")

$path
$path.GetType()
$method = "GetType"
$path.$method()
# Code conversion from C# to PowerShell
# http://msdn.microsoft.com/en-us/library/windows/apps/hh802768.aspx

# nuget Windows 7 API Code Pack -Shell 
# http://nugetmusthaves.com/Package/Windows7APICodePack-Shell
# Install-Package Windows7APICodePack-Shell
Add-Type -Path .\Microsoft.WindowsAPICodePack.dll
Add-Type -Path .\Microsoft.WindowsAPICodePack.Shell.dll

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[xml]$toastXml =  ([Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText04)).GetXml()

$stringElements = $toastXml.GetElementsByTagName("text")
for ($i = 0; $i -lt $stringElements.Count; $i++)
{
    $stringElements[$i].AppendChild($toastXml.CreateTextNode("Line " + $i)) > $null
}

$imageElements = $toastXml.GetElementsByTagName("image")
$imageElements[0].src = "file:///" + ""

$windowsXml = New-Object Windows.Data.Xml.Dom.XmlDocument
$windowsToastXml = $windowsXml.LoadXml($toastXml.OuterXml)
$toast = New-Object Windows.UI.Notifications.ToastNotification ($windowsXml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("hoge").Show($toast)
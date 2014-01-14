# Code conversion from C# to PowerShell
# http://msdn.microsoft.com/en-us/library/windows/apps/hh802768.aspx

# nuget Windows 7 API Code Pack -Shell 
# http://nugetmusthaves.com/Package/Windows7APICodePack-Shell
# Install-Package Windows7APICodePack-Shell
Add-Type -Path .\Microsoft.WindowsAPICodePack.dll
Add-Type -Path .\Microsoft.WindowsAPICodePack.Shell.dll

# create toast template TO xml
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[xml]$toastXml =  ([Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText04)).GetXml()

# message to show on toast
$stringElements = $toastXml.GetElementsByTagName("text")
for ($i = 0; $i -lt $stringElements.Count; $i++)
{
    $stringElements[$i].AppendChild($toastXml.CreateTextNode("Line " + $i)) > $null
}

<#
# こっちもあり
$stringElements = $toastXml.GetElementsByTagName("text") | select -First 1
$stringElements.AppendChild($toastXml.CreateTextNode("Test Toast Notification")) > $null
#>

# no image
$imageElements = $toastXml.GetElementsByTagName("image")
$imageElements[0].src = "file:///" + ""

# convert from System.Xml.XmlDocument to Windows.Data.Xml.Dom.XmlDocument
$windowsXml = New-Object Windows.Data.Xml.Dom.XmlDocument
$windowsXml.LoadXml($toastXml.OuterXml)

$APP_ID = "hoge"
$shortcutPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData) + "\Microsoft\Windows\Start Menu\Programs\hoge.lnk";

# send toast notification
$toast = New-Object Windows.UI.Notifications.ToastNotification ($windowsXml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($APP_ID).Show($toast)
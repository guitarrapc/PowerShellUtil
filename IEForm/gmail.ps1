$cred = Get-Credential -Message 'Input credential for login'
$ie = New-Object -ComObject InternetExplorer.Application
$ie.visible = $true
$ie.navigate('https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=ja')
while ($ie.ReadyState -ne 4){Start-Sleep -Milliseconds 100}
$ie.Document.getElementById('email').value = $cred.UserName
$ie.Document.getElementById('Passwd').value = $cred.GetNetworkCredential().Password
$ie.Document.getElementById('SignIn').Click()
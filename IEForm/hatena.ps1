$cred = Get-Credential -Message 'Input credential for login'
$ie = New-Object -ComObject InternetExplorer.Application
$ie.visible = $true
$ie.navigate('https://www.hatena.ne.jp/login')
while ($ie.ReadyState -ne 4){Start-Sleep -Milliseconds 100}
$ie.Document.getElementById('name').value = $cred.UserName
$ie.Document.getElementById('password').value = $cred.GetNetworkCredential().Password
($ie.Document.getElementsByTagName('input') | where type -eq 'submit').click()
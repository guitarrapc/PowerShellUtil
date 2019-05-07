## Run remote command directly

```powershell
iex  (new-object net.webclient).downloadstring('https://raw.githubusercontent.com/guitarrapc/PowerShellUtil/master/WindowsDefender/remote_exec.ps1')
```
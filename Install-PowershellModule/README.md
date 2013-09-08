Install-PowershellModule
==========

Copy items in current directory of install.ps1 to PowerShell Module path "$env:userProfile\documents\WindowsPowerShell\Modules".

# Usage

1. Include install.bat and install.ps1 to your module respository.
1. Clone PowerShell Module Repository of yours.
1. Goto clone path in your local computer and execute install.bat
1. all the items in clone repository will be copy to "$env:userProfile\documents\WindowsPowerShell\Modules" as same as direcotry structure of repository.


# bat file execute powershell ps1

install.bat execute command as below.
If you not yet execute Set-ExecutionPolicy then run install.bat as admin,

```text
PowerShell -Command {Set-Executionpolicy RemoteSigned}
PowerShell .\Install.ps1
```

# Cmdlet

Here's cmdlet included in install.ps1

You can specify $modulepath if demand, default is "$env:userProfile\documents\WindowsPowerShell\Modules".
```PowerShell
Copy-Module
Get-OperatingSystemVersion 
New-ModulePath
Test-ModulePath 
```

### Get-OperatingSystemVersion

Returns Win32_OperatingSystem.Version property.
```
Get-OperatingSystemVersion
```

### Test-ModulePath

Test "$env:userProfile\documents\WindowsPowerShell\Modules" is exist or not.
This Cmdlet will only work with Windows 8 / Windows Server 2012 and later. (It requires Operation System Version for 6, means Windows 8 = PowerShell 3.0 and later)
It will returns bool for result.

```
Test-ModulePath [-modulepath] <string>  [<CommonParameters>]
```

### New-ModulePath

Create Module path if not exist.

```
New-ModulePath [-modulepath] <string>  [<CommonParameters>]
```

### Copy-Module

Copy items to module path "$env:userProfile\documents\WindowsPowerShell\Modules".

```
Copy-Module [-path] <string> [-destination] <string>  [<CommonParameters>]
```

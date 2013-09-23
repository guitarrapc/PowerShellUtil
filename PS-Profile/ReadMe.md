# Cmdlets

You may find cmdlets include this module as.....

```Powershell
PS C:\Windows\System32\WindowsPowerShell\v1.0> Get-Command -Module PS-Profile | ft -AutoSize

CommandType Name             ModuleName
----------- ----             ----------
Function    Backup-PSProfile PS-Profile
Function    Edit-PSProfile   PS-Profile
Function    Get-PSProfile    PS-Profile
Function    New-PSProfile    PS-Profile
Function    Remove-PSProfile PS-Profile
Function    Test-PSProfile   PS-Profile
```

## Common Swtiches

All PS-Profile Cmndlets offer you common switch for profile path selection.

Put switch for Profile you want to create from below.

```Powershell
-CurrentUserAllHosts          : Current user's both PowerShell.exe and PowerShell_ise.exe will be affect.
--CurrentUserCurrentPSHost    : Current user's PowerShell.exewill be affect.
--CurrentUserCurrentPSISEHost : Current user's PowerShell_ise.exe will be affect.
-AllUsersAllHosts             : All user's both PowerShell.exe and PowerShell_ise.exe will be affect.
-AllUsersCurrentPSHost        : All user's both PowerShell.exe will be affect.
-AllUsersCurrentPSISEHost     : All user's both PowerShell_ise.exe will be affect.
```

# How Cmdlets works
|Cmdlets|Description|
|:--:|--|
|Backup-PSProfile|This Cmdlet will backup you profile to backup folder under profile path.|
|Edit-PSProfile|If you run with psise, then profile file will on in psise, if not then notepad will open|
|Get-PSProfile|This Cmdlet will Get Profile file information.|
|New-PSProfile|This Cmdlet will create Profile file.|
|Remove-PSProfile|This Cmdlet will remove Profile file.|
|Test-PSProfile|This Cmdlet will return bool for profile exist.|


# Sample

## New-PSProfile

- Create new profile for current users all hosts

```PowerShell
New-PSProfile -CurrentUserAllHosts
```

- Create new profile for all users all hosts

```PowerShell
New-PSProfile -AllUsersAllHosts
```

## Test-PSProfile

- Test profile for current users all hosts is exit

```PowerShell
Test-PSProfile -CurrentUserAllHosts
```

## Get-PSProfile

- Get profile file information for current users all hosts

```PowerShell
Get-PSProfile -CurrentUserAllHosts
```

## Edit-PSProfile

- Edit profile for current users all hosts in new psise tab if run will psise, else open notepad.

```PowerShell
Test-PSProfile -CurrentUserAllHosts
```


## Backup-PSProfile

- Backup profile for current users all hosts
- Default 3 times retention. (add -retenction to change duration)

```PowerShell
Backup-PSProfile -CurrentUserAllHosts
```

## Remove-PSProfile

- Remove profile for current users all hosts

```PowerShell
Remove-PSProfile -CurrentUserAllHosts
```

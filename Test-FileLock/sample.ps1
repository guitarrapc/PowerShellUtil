
#region Test-FileLock will return file lock status for the file

# true for locked file
Test-FileLock -Path 'C:\Program Files\Windows NT\Accessories\wordpad.exe'

# false for not locked file
Test-FileLock -Path 'D:\Software\SumoLogics\SumoCollector_linux_amd64_19_40-8.sh'

# blank for Directory (as it always returns true)
# Add -Verbose if you want to check if it were not file
Test-FileLock -path D:\Hyper-V -Verbose

# error for not exist
# Add -Verbose if you want to check if it were not file
Test-FileLock -Path D:\ge

# access error
Test-FileLock -path "C:\Windows\System32\LogFiles\HTTPERR\httperr1.log"

# Path recurse
Get-ChildItem -path $env:USERPROFILE -Recurse | %{Test-FileLock -path $_.FullName -Verbose}

# Registry is ignore
Get-FileLock -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion

# Environment Variables is ignored
Get-FileLock -Path $env:AMDAPPSDKROOT

#endregion


#region Get-FileLock will return file name and file lock status for the file

# locked file
Get-FileLock -Path 'C:\Program Files\Windows NT\Accessories\wordpad.exe'

# not locked file
Get-FileLock -Path 'D:\Software\SumoLogics\SumoCollector_linux_amd64_19_40-8.sh'

# blank for Directory (as it always returns true)
# Add -Verbose if you want to check if it were not file
Get-FileLock -path D:\Hyper-V -Verbose

# not exist
Get-FileLock -Path D:\ge

# access error
Get-FileLock -path "C:\Windows\System32\LogFiles\HTTPERR\httperr1.log"

# Path recurse
Get-ChildItem -path $env:USERPROFILE -Recurse | %{Get-FileLock -path $_.FullName -Verbose}

# Registry is ignore
Get-FileLock -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion

# Environment Variables is ignored
Get-FileLock -Path $env:AMDAPPSDKROOT

#endregion
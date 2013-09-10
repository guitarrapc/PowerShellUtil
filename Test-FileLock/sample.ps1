
#region Test-FileLock will return file lock status for the file

# true for locked file
Test-FileLock -Path 'C:\Program Files\Windows NT\Accessories\wordpad.exe' -Verbose

# false for not locked file
Test-FileLock -Path 'D:\Software\SumoLogics\SumoCollector_linux_amd64_19_40-8.sh' -Verbose

# blank for Directory (as it always returns true)
Test-FileLock -path D:\Hyper-V -Verbose

# error for not exist
Test-FileLock -Path D:\ge -Verbose

# access error
Test-FileLock -path "C:\Windows\System32\LogFiles\HTTPERR\httperr1.log" -Verbose

#endregion


#region Get-FileLock will return file name and file lock status for the file

# locked file
Get-FileLock -Path 'C:\Program Files\Windows NT\Accessories\wordpad.exe' -Verbose

# not locked file
Get-FileLock -Path 'D:\Software\SumoLogics\SumoCollector_linux_amd64_19_40-8.sh' -Verbose

# Directory (as it always returns true)
Get-FileLock -path D:\Hyper-V -Verbose

# not exist
Get-FileLock -Path D:\ge -Verbose

# access error
Get-FileLock -path "C:\Windows\System32\LogFiles\HTTPERR\httperr1.log" -Verbose

#endregion
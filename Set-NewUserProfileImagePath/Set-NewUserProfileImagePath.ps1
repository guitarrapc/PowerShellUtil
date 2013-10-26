#Requires -RunAsAdministrator

function Set-NewUserProfileImagePath
{
<#
.Example
# change username share's userFolder from c:\users\share to c:\users\hoge
Set-NewUserProfileImagePath -user share -currentUserFolderName share -newUserFolderName hoge -Verbose

.Example
# evenif userfolder name not same as username, you can change username share's userFolder from c:\users\hoge to c:\users\share
Set-NewUserProfileImagePath -user share -currentUserFolderName hoge -newUserFolderName share -Verbose

.Example
# with -force switch, you can force input desired imagepath c:\users\share to registry for user share. This never depend on how userfolder is set
Set-NewUserProfileImagePath -user share -currentUserFolderName hoge -newUserFolderName share -Verbose -Foce

#>
    [CmdletBinding()]
    param
    (
        # enter username to be changed
        [parameter(
            mandatory,
            position = 0)]
        [string]
        $user,

        # enter current user folder name to be changed
        [parameter(
            mandatory,
            position = 1)]
        [string]
        $currentUserFolderName,

        # enter new user Folder name change to
        [parameter(
            mandatory,
            position = 2)]
        [string]
        $newUserFolderName,

        # enter new user Folder name change to
        [switch]
        $force
    )

    begin
    {
        # get foler information
        $private:usersFolder = Split-Path $env:USERPROFILE -Parent
        $private:currentUserFolder = Get-ChildItem $usersFolder | where PSISContainer | where Name -eq $currentUserFolderName
        $private:newuserFolder = Join-Path $usersFolder $newUserFolderName
        
        # get registry information
        $private:registryPath = "registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
        $private:users = Get-CimInstance Win32_UserAccount            
        $private:sid = $users.Where({$_.Name -eq $user}).SID

        # set registry information
        $private:regSidDetail = Get-ItemProperty -Path (Join-Path $registryPath $sid)
        $private:currentProfileImagePath = $regSidDetail.ProfileImagePath
        $private:newProfileImagePath = if ($force)
            {
                $newuserFolder
            }
            elseif($currentProfileImagePath -eq $currentUserFolder.FullName)
            {
                $newuserFolder
            }
            else
            {
                $null
            }
    }

    process
    {

        if ($user -ne $env:USERNAME)
        {

            # userFolder change
            Write-Verbose ("Start changing user Folder '{0}' to '{1}'" -f $currentUserFolder.FullName, $newuserFolder)
            if($currentUserFolder.FullName)
            {
                if ($currentUserFolder.FullName -ne $newuserFolder)
                {
                    Rename-Item -Path $currentUserFolder.FullName -NewName $newuserFolder -PassThru -Confirm
                }
                else
                {
                    Write-Warning ("newUserFolder '{0}' detected as same as currentUserFolder '{1}'." -f $newUserFolder, $currentUserFolder.FullName)
                }
            }
            else
            {
                Write-Warning ("currentUserFolder '{0}' detected as null." -f $currentUserFolder.FullName)
            }
            
            # registry change
            Write-Verbose ("Start changing Registry from '{0}' to {1} , for user '{2}' with sid '{3}'" -f $currentProfileImagePath, $newProfileImagePath, $user, $sid)
            if ($newProfileImagePath)
            {
                if ($newProfileImagePath -ne $currentProfileImagePath)
                {
                    Set-ItemProperty -Path "registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" -Name ProfileImagePath -Value $newProfileImagePath -Confirm -PassThru
                }
                else
                {
                    Write-Warning ("newProfileImagePath '{0}' detected as same as currentProfileImagePath '{1}'" -f $newProfileImagePath, $currentProfileImagePath)
                }
            }
            else
            {
                Write-Warning ("newProfileImagePath '{0}' detected as null." -f $newProfileImagePath)
            }
        }
        else
        {
            Write-Warning ("Current user '{0}' is same as target user '{1}'. Please execute this command with other user who have admin priviledge"-f $env:USERNAME, $user)
        }
    }
        
    end
    {
    }
}
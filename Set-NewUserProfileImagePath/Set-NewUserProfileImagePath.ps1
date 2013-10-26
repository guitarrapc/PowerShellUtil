#Requires -RunAsAdministrator

function Set-NewUserProfileImagePath
{
<#
.Example
Set-NewUserProfileImagePath -user share -newuser hoge -Verbose
#>
    [CmdletBinding()]
    param
    (
        # enter current user name to be changed
        [parameter(
            mandatory,
            position = 0)]
        $user,

        # enter new user name
        [parameter(
            mandatory,
            position = 0)]
        $newuser
    )

    begin
    {
        # get foler information
        $usersFolder = Split-Path $env:USERPROFILE -Parent
        $currentUserFolder = Get-ChildItem $usersFolder | where PSISContainer | where Name -eq $user
        $newuserFolder = Join-Path $usersFolder $newuser
        
        # get registry information
        $registryPath = "registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
        $users = Get-CimInstance Win32_UserAccount            
        $sid = $users.Where({$_.Name -eq $user}).SID
    }

    process
    {

        if ($user -ne $env:USERNAME)
        {
            Write-Verbose ("Start changing user Folder '{0}' to '{1}'" -f $currentUserFolder.FullName, $newuserFolder)
            if($currentUserFolder)
            {
                if ($currentUserFolder.FullName -ne $newuserFolder)
                {
                    Rename-Item -Path $currentUserFolder.FullName -NewName $newuserFolder -PassThru -Confirm
                }

                Write-Verbose ("Start changing Registry '{0}' for user '{1}' with sid '{2}'" -f $registryPath, $user, $sid)
                $regSidDetail = Get-ItemProperty -Path (Join-Path $registryPath $sid)
                $newProfileImagePath = if ($regSidDetail.ProfileImagePath -eq $currentUserFolder.FullName){$newuserFolder}else{$null}
                if ($newProfileImagePath)
                {
                    Set-ItemProperty -Path "registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" -Name ProfileImagePath -Value $newProfileImagePath -Confirm -PassThru
                }
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


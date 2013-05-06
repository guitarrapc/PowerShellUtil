#Requires -Version 3.0

function Set-EnvUserProfilePath{

    Write-Host "Adding UserProfilepath for ssh-Keygen."

    if (!($Env:HOME -match ($env:USERPROFILE.replace("\","\\"))))
    {
        $Env:HOME += $env:USERPROFILE
    }
    else
    {
        Write-Host "UserProfile path had already been added to HOME. nothing will do." -ForegroundColor Green
    }


}
# Requires -Version 3.0

function New-UserModulePath{

    $userPSroot = $env:PSModulePath -split ";" | where {$_ -like ("{0}*" -f (Split-Path $profile -Parent))}

    if(-not(Test-Path $userPSroot))
    {
        New-Item -Path $userPSroot -ItemType Directory -Force    
    }
}


function New-PSProfile{
    
    [CmdletBinding(DefaultParameterSetName="CurrentUserAllHosts")]
    param(
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSHost,
        
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSISEHost,       

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSHost,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSISEHost        
    )
    
    # root path
    $user = "$env:USERPROFILE\Documents\WindowsPowerShell\"

    switch ($true)
    {
        $CurrentUserCurrentPSHost       {$currentProfile = Join-Path $user "Microsoft.PowerShell_profile.ps1"
                              New-UserModulePath}
        $CurrentUserCurrentPSISEHost    {$currentProfile = Join-Path $user "Microsoft.PowerShellISE_profile.ps1"
                              New-UserModulePath}
        $CurrentUserAllHosts   {$currentProfile = $profile.CurrentUserAllHosts
                              New-UserModulePath}
        $AllUsersCurrentPSHost     {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShell_profile.ps1"}
        $AllUsersCurrentPSISEHost  {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShellISE_profile.ps1"}
        $AllUsersAllHosts {$currentProfile = $profile.AllUsersAllHosts}
    }

    if (-not(Test-Path $currentProfile))
    {
        New-Item -Path $currentProfile -ItemType File -Force
    }
    else
    {
        Write-Warning ("Profile already exit at {0}. nothing will do." -f $currentProfile)
    }
}


function Get-PSProfile{
    
    [CmdletBinding(DefaultParameterSetName="CurrentUserAllHosts")]
    param(
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSHost,
        
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSISEHost,       

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSHost,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSISEHost        
    )
    
    # root path
    $user = "$env:USERPROFILE\Documents\WindowsPowerShell\"

    switch ($true)
    {
        $CurrentUserCurrentPSHost       {$currentProfile = Join-Path $user "Microsoft.PowerShell_profile.ps1"}
        $CurrentUserCurrentPSISEHost    {$currentProfile = Join-Path $user "Microsoft.PowerShellISE_profile.ps1"}
        $CurrentUserAllHosts   {$currentProfile = $profile.CurrentUserAllHosts}
        $AllUsersCurrentPSHost     {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShell_profile.ps1"}
        $AllUsersCurrentPSISEHost  {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShellISE_profile.ps1"}
        $AllUsersAllHosts {$currentProfile = $profile.AllUsersAllHosts}
    }

    if (Test-Path $currentProfile)
    {
        Get-Item -Path $currentProfile
    }
    else
    {
        Write-Warning ("Profile could not found from {0}" -f $currentProfile)
    }
}


function Test-PSProfile{
    
    [CmdletBinding(DefaultParameterSetName="CurrentUserAllHosts")]
    param(
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSHost,
        
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSISEHost,       

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSHost,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSISEHost        
    )
    
    # root path
    $user = "$env:USERPROFILE\Documents\WindowsPowerShell\"

    switch ($true)
    {
        $CurrentUserCurrentPSHost       {$currentProfile = Join-Path $user "Microsoft.PowerShell_profile.ps1"}
        $CurrentUserCurrentPSISEHost    {$currentProfile = Join-Path $user "Microsoft.PowerShellISE_profile.ps1"}
        $CurrentUserAllHosts   {$currentProfile = $profile.CurrentUserAllHosts}
        $AllUsersCurrentPSHost     {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShell_profile.ps1"}
        $AllUsersCurrentPSISEHost  {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShellISE_profile.ps1"}
        $AllUsersAllHosts {$currentProfile = $profile.AllUsersAllHosts}
    }

    Test-Path $currentProfile
}



function Edit-PSProfile{
    
    [CmdletBinding(DefaultParameterSetName="CurrentUserAllHosts")]
    param(
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSHost,
        
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSISEHost,       

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSHost,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSISEHost        
    )
    
    # root path
    $user = "$env:USERPROFILE\Documents\WindowsPowerShell\"

    switch ($true)
    {
        $CurrentUserCurrentPSHost       {$currentProfile = Join-Path $user "Microsoft.PowerShell_profile.ps1"}
        $CurrentUserCurrentPSISEHost    {$currentProfile = Join-Path $user "Microsoft.PowerShellISE_profile.ps1"}
        $CurrentUserAllHosts   {$currentProfile = $profile.CurrentUserAllHosts}
        $AllUsersCurrentPSHost     {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShell_profile.ps1"}
        $AllUsersCurrentPSISEHost  {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShellISE_profile.ps1"}
        $AllUsersAllHosts {$currentProfile = $profile.AllUsersAllHosts}
    }

    if (Test-Path $currentProfile)
    {
        if ($psise)
        {
            psedit $currentProfile
        }
        else
        {
            notepad.exe $currentProfile
        }
    }
    else
    {
        Write-Warning ("Profile could not found from {0}" -f $currentProfile)
    }
}

function Remove-PSProfile{
    
    [CmdletBinding(DefaultParameterSetName="CurrentUserAllHosts")]
    param(
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSHost,
        
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSISEHost,       

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSHost,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSISEHost        
    )
    
    # root path
    $user = "$env:USERPROFILE\Documents\WindowsPowerShell\"

    switch ($true)
    {
        $CurrentUserCurrentPSHost       {$currentProfile = Join-Path $user "Microsoft.PowerShell_profile.ps1"}
        $CurrentUserCurrentPSISEHost    {$currentProfile = Join-Path $user "Microsoft.PowerShellISE_profile.ps1"}
        $CurrentUserAllHosts   {$currentProfile = $profile.CurrentUserAllHosts}
        $AllUsersCurrentPSHost     {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShell_profile.ps1"}
        $AllUsersCurrentPSISEHost  {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShellISE_profile.ps1"}
        $AllUsersAllHosts {$currentProfile = $profile.AllUsersAllHosts}
    }

    if (Test-Path $currentProfile)
    {
        Remove-Item -Path $currentProfile -Force -Confirm 
    }
    else
    {
        Write-Warning ("Profile could not found from {0}" -f $currentProfile)
    }
}



function Backup-PSProfile{
    
    [CmdletBinding(DefaultParameterSetName="CurrentUserAllHosts")]
    param(
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSHost,
        
        [parameter(
            mandatory,
            position = 0,
            parametersetname = "CurrentUserCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $CurrentUserCurrentPSISEHost,       

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersAllHosts",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersAllHosts,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSHost,

        [parameter(
            mandatory,
            position = 0,
            parametersetname = "AllUsersCurrentPSISEHost",
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [switch]
        $AllUsersCurrentPSISEHost,

        [parameter(
            mandatory = 0,
            position = 1,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [int]
        $retention = 3
    )
    
    # root path
    $user = "$env:USERPROFILE\Documents\WindowsPowerShell\"

    #backup folder name
    $backup = "ProfileBackup"

    switch ($true)
    {
        $CurrentUserCurrentPSHost       {$currentProfile = Join-Path $user "Microsoft.PowerShell_profile.ps1"
                              $backupProfile  = Join-Path $user $backup}
        $CurrentUserCurrentPSISEHost    {$currentProfile = Join-Path $user "Microsoft.PowerShellISE_profile.ps1"
                              $backupProfile  = Join-Path $user $backup}
        $CurrentUserAllHosts   {$currentProfile = $profile.CurrentUserAllHosts
                              $backupProfile  = Join-Path $user $backup}
        $AllUsersCurrentPSHost     {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShell_profile.ps1"
                              $backupProfile  = Join-Path $PSHOME $backup}
        $AllUsersCurrentPSISEHost  {$currentProfile = Join-Path $PSHOME "Microsoft.PowerShellISE_profile.ps1"
                              $backupProfile  = Join-Path $PSHOME $backup}
        $AllUsersAllHosts {$currentProfile = $profile.AllUsersAllHosts
                              $backupProfile  = Join-Path $PSHOME $backup}
    }

    if (-not(Test-Path $backupProfile))
    {
        New-Item -Path $backupProfile -ItemType Directory -Force
    }

    if (Test-Path $currentProfile)
    {
        # backup
        Write-Host ("Copying {0} to Backup {1}" -f $currentProfile, $backupProfile) -ForegroundColor Cyan
        Copy-Item -Path $currentProfile -Destination $backupProfile -Force

        # get backup result
        $backupfiles = Get-ChildItem -Path $backupProfile | where extension -eq ".ps1"

        # backup retension
        if ($backupfiles.count -gt $retention)
        {
            $removebackup = $backupfiles | sort LastWriteTime | select -First 1
            Remove-Item -Path $removebackup.fullname -Force
        }

        #show backup status
        Write-Host ("Current Backup status of {0}" -f $backupProfile) -ForegroundColor Cyan
        Get-ChildItem -Path $backupProfile | where extension -eq ".ps1"
    }
    else
    {
        Write-Warning ("Profile could not found from {0}" -f $currentProfile)
    }
}


# export module
Export-ModuleMember -Function "*-PS*"
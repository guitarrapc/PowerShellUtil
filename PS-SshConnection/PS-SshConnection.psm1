#Requires -Version 3.0

Write-Verbose "Loading PS-SshConnection.psm1"

# PS-SshConnection
#
# Copyright (c) 2013 guitarrapc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


#-- Chocolatey and Package Installation --#


function New-ChocolateryInstall {

    param(
    [bool]$ShowMan=$false
    )

    Write-Host "Checking for chocolatery installation."

    try
    {
        Import-Module C:\Chocolatey\chocolateyinstall\helpers\chocolateyInstaller.psm1
    }
    catch
    {
        Invoke-Expression ((new-object Net.Webclient).DownloadString("http://bit.ly/psChocInstall"))
    }

    if (!(Get-Module chocolateyInstaller))
    {
        Invoke-Expression ((new-object Net.Webclient).DownloadString("http://bit.ly/psChocInstall"))
    }
    else
    {
        Write-Host "chocolatery had already been installed. nothing will do." -ForegroundColor Green
    }

    switch ($true){
    $ShowMan {Get-ChocolateryInstructions}
    default{ Write-Host "    - If you want to check simple chocolatery usage, add -ShowMan $true." -ForegroundColor Yellow}
    }

}




function New-ChocolateryMsysgitInstall {

    Write-Host "Checking for msysgit installation."

    if (!(Get-ChildItem -path "C:\Chocolatey\lib" -Recurse -Directory | ? {$_.Name -like "msysgit*"}))
    {
        cinst msysgit
    }
    else
    {
        Write-Host "msysgit had already been installed. nothing will do." -ForegroundColor Green
    }

}



#-- Set Git environmet --#


function Set-EnvGitPath{

    Write-Host "Adding Git path for PowerShell Command."

    if (!($env:path -match "C:\\Program Files \(x86\)\\git\\bin\\;"))
    {
        $Env:Path += ";C:\Program Files (x86)\Git\bin\"
        Write-Host 'git path "C:\Program Files (x86)\Git\bin\" had been added to PATH.' -ForegroundColor Green
    }
    else
    {
        Write-Host 'git path "C:\Program Files (x86)\Git\bin\" had already been added to PATH. nothing will do.' -ForegroundColor Green
    }
}



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




#-- Test Ssh is already installed or not --#


function Test-SshInstallationStatus{

    [CmdletBinding()]
    param(
        [parameter(
            position = 0,
            mandatory = 0,
            ValueFromPipeLine = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $chocolateypath = "C:\Chocolatey\chocolateyinstall",

        [parameter(
            position = 1,
            mandatory = 0,
            ValueFromPipeLine = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $gitpath = "C:\Program Files (x86)\Git"
    )
    

    # Install Chocoratey
    if (-not(Test-Path $chocolateypath))
    {
        try
        {
            New-ChocolateryInstall
        }
        catch
        {
            throw $_
        }
    }
    else
    {
        Write-Verbose "Chocolatey already installed....done!"
    }


    # Install Msysgit
    if (-not(Test-Path $gitpath))
    {
        try
        {
            New-ChocolateryMsysgitInstall -ErrorAction Stop
        }
        catch
        {
            throw $_
        }
    }
    else
    {
        Write-Verbose "git already installed....done!"
    }

}



#-- Create SSH Session and invoke command --#


function Invoke-SshCommand{

    [CmdletBinding()]
    param(
        [parameter(
            position = 0,
            mandatory = 1,
            ValueFromPipeLine = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $rsaKey,

        [parameter(
            position = 1,
            mandatory = 1,
            ValueFromPipeLine = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $user,

        [parameter(
            position = 2,
            mandatory = 1,
            ValueFromPipeLine = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $hostip,

        [parameter(
            position = 3,
            mandatory = 1,
            ValueFromPipeLine = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $command,

        [parameter(
            position = 4,
            mandatory = 0,
            ValueFromPipeLine = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $option="",

        [parameter(
            position = 5,
            mandatory = 0,
            ValueFromPipeLine = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string]
        $option2=""
              
    )

    begin
    {
        Write-Verbose "Check Log Folder is exist or not"
        New-PSSshLogFolder

        Write-Verbose "Check Ssh Status"
        Test-SshInstallationStatus

        Write-Verbose "Set GitPath"
        Set-EnvGitPath

        Write-Verbose "Set User Profile Path"
        Set-EnvUserProfilePath

        Write-Verbose "prefix command to avoid trusted option"
        $prefixoption1 = "StrictHostKeyChecking=no"
        $prefixoption2 = "UserKnownHostsFile=/dev/null"
        $prefixoption3 = "LogLevel=quiet"
    }

    process
    {
        if(($option -ne "") -and ($option2 -ne ""))
        {
            Write-Verbose "実行コマンド : ssh -i $rsaKey $user@$hostip -o $option -o $option2 -o $prefixoption1 -o $prefixoption2 -o $prefixoption3 $command"
            ssh -i $rsaKey $user@$hostip -o $option -o $option2 -o $prefixoption1 -o $prefixoption2 -o $prefixoption3 $command
        }
        elseif ($option -ne "")
        {
            Write-Verbose "実行コマンド : ssh -i $rsaKey $user@$hostip -o $option -o $prefixoption1 -o$prefixoption2 -o $prefixoption3 $command"
            ssh -i $rsaKey $user@$hostip -o $option -o $prefixoption1 -o $prefixoption2 -o $prefixoption3 $command
        }
        else
        {
            Write-Verbose "実行コマンド : ssh -i $rsaKey $user@$hostip -o $prefixoption1 -o $prefixoption2 -o $prefixoption3 $command"
            ssh -i $rsaKey $user@$hostip -o $prefixoption1 -o $prefixoption2 -o $prefixoption3 $command
        }
    }

    end
    {
        
    }
}




#-- Invoke Capistrano Deploy --#

function Invoke-CapistranoDeploy{

    [CmdletBinding()]
    param(

        [parameter(
        position = 0,
        mandatory = 1
        )]
        [string]
        $deploygroup,

        [parameter(
        position = 1,
        mandatory = 1
        )]
        [string]
        $captask,

        [parameter(
        position = 2,
        mandatory = 1
        )]
        [string]
        $deploypath,

        [parameter(
        position = 3,
        mandatory = 1
        )]
        [string]
        $rsakey,

        [parameter(
        position = 4,
        mandatory = 1
        )]
        [string]
        $user,

        [parameter(
        position = 5,
        mandatory = 1
        )]
        [string]
        $hostip
    )

    begin
    {

        # define cap command
        Write-Verbose "define basecommand : source .bash_profile; cd $deploypath;"
        $basecommand = "source .bash_profile; cd $deploypath;"

        Write-Verbose "define cap command : cap $deploygroup $captask;"
        $capcommand = "cap $deploygroup $captask;"

        Write-Verbose "define ssh command : $basecommand + $capcommand"
        $command = $basecommand + $capcommand


        # define splating for ssh command
        $sshparam = @{
            rsakey = $rsakey
            user = $user
            hostip = $hostip
            command = $command
        }    

        # Show define result
        Write-Warning "Set -Verbose switch to check ssh command variables and Detail"
        Write-Verbose "rsakey   : $rsakey"
        Write-Verbose "user     : $user"
        Write-Verbose "hostip   : $hostip"
        Write-Verbose "command  : $command"
    }

    process
    {
        # runcommand
        Invoke-SshCommand @sshparam -ErrorAction Continue 2>&1 | %{
            
            # Host Display
            if (($_ -like "*error*") -or ($_ -like "*failed*") -or ($_ -like "*fatal*"))
            {
                Write-Host $_ -ForegroundColor Red
            }
            elseif ($_ -like "*the task * does not exist*")
            {
                Write-Host $_ -ForegroundColor Yellow
            }
            else
            {
                Write-Host $_
            }
            

            # Log Output
            if ($_.Message -eq $null)
            {
                $_ | Out-File -FilePath $psssh.Log.path -Encoding utf8 -Append
            }
            else
            {
                $_.Message | Out-File -FilePath $psssh.Log.path -Encoding utf8 -Append
            }

        }

    }

    end
    {       
    }
}




#-- Test Log Folder --#


function New-PSSshLogFolder{

    [CmdletBinding()]
    param(
    )

    # Set Log
    $psssh.log.date = Get-Date # Set Log Date
    $psssh.log.extention = ".log" # Set Log Extention
    $psssh.log.root = "C:\Logs\Deployment" # Set Log Path
    $psssh.log.datefolder = Join-Path "C:\Logs\Deployment" $psssh.Log.date.ToString("yyyyMMdd") # Set Log Date Path
    $psssh.log.name = "PSSsh" + "_" + ($psssh.log.date).ToString("yyyyMMdd_HHmmss") # Set Log Name
    $psssh.log.path = [System.IO.Path]::ChangeExtension((Join-Path $psssh.log.datefolder $psssh.log.name),$psssh.log.extention) # Set Log full path


    # Check and Create Log Folders
    if (-not(Test-Path $psssh.log.root))
    {
        Write-Verbose "LogFolder not found creating $($psssh.log.root)"
        New-Item -Path $psssh.log.root -ItemType Directory > $null
    }

    if (-not(Test-Path $psssh.log.datefolder))
    {
        Write-Verbose "LogFolder not found creating $logdatefolder"
        New-Item -Path $psssh.log.datefolder -ItemType Directory > $null
    }


}



## variable Setup ##

# contains default base configuration, may not be override without version update.
$Script:psssh = @{}
$psssh.name = "PSSsh" # contains the Name of Module
$psssh.version = "0.0.2" # contains the current version
$psssh.log = @{}


## Alias Setup ##

#-- Set Alias for public valentia commands --#

Write-Verbose "Set Alias."

New-Alias -Name sshcommand -Value Invoke-SshCommand
New-Alias -Name deploy -Value Invoke-CapistranoDeploy



## Load External Modules ##

Write-Verbose "Loading external modules."
# . $PSScriptRoot\*.ps1


## Export Internal Cmdlets ##

Write-Verbose "Exporting Internal Cmdlets."
Export-ModuleMember `
    -Function * `
    -Variable psssh `
    -Alias *
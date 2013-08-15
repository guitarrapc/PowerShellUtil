#Requires -Version 3.0

function New-SumoCredential{

    [CmdletBinding()]
    param(
        [string]
        [Parameter(
            Position = 0,
            Mandatory = 0)]
        [string]
        $save = "$PSScriptRoot",

        [Parameter(
            Position = 1,
            Mandatory = 0)]
        [string]
        $User
    )


    $cred = Get-Credential -UserName $User -Message "Input $User Password to be save."


    if ($User -eq "")
    {
        $User = $cred.UserName
    }
        
    if ((Test-Path $save) -and (-not([string]::IsNullOrEmpty($cred.Password))))
    {

        # Set CredPath with current Username
        $CredPath = Join-Path $save "$User.pass"

        # get SecureString
        try
        {
            $savePass = $cred.Password | ConvertFrom-SecureString
        }
        catch
        {
            throw 'Credential input was empty!! "None pass" is not allowed.'
        }

        
        
        if (Test-Path $CredPath)
        {
            Write-Verbose "Remove existing Credential Password for $User found in $CredPath"
            Remove-Item -Path $CredPath -Force -Confirm
        }


        Write-Verbose "Save Credential Password for $User set in $CredPath"
        $savePass | Set-Content -Path $CredPath -Force


        Write-Verbose "Completed: Credential Password for $User had been sat in $CredPath"
    }
    else
    {
        Write-Host "PSScriptRoot : $PSScriptRoot"
        Write-Host "'$cred.Password' : $(-not([string]::IsNullOrEmpty($cred.Password)))"
    }

}


function Get-SumoCredential{

    [CmdletBinding()]
    param(
        [string]
        [Parameter(
            Position = 0,
            Mandatory = 0)]
        [string]
        $save = "$PSScriptRoot",

        [Parameter(
            Position = 1,
            Mandatory = 1)]
        [string]
        $User,

        [switch]
        $force
    )


    # Set CredPath with current Username
    $credPath = Join-Path $save "$User.pass"

    if (Test-Path $credPath)
    {
        $credPassword = Get-Content -Path $CredPath | ConvertTo-SecureString

        if ($credPassword -ne $null)
        {
            Write-Verbose "Obtain credential for User [ $User ] from $CredPath "
            $cred = New-Object System.Management.Automation.PSCredential ($user, $Credpassword)
        }
        elseif ($force)
        {
            Write-Verbose "force overrive current credential for User [ $User ] from $CredPath"
            $cred = New-Object System.Management.Automation.PSCredential ($user, $Credpassword)
        }
        else
        {
            Write-Host "Credential already created, skip Get-SumoCredential" -ForegroundColor Cyan
        }
    }
    else
    {
        throw "Credential not created yet. Please run New-SumoCredential to obtain credential."
    }


    return $cred

}


function Get-SumoApiCollectors{

    [CmdletBinding(
    )]
    param(
        [parameter(
            position = 0,
            mandatory = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $CollectorIds = $null,

        [parameter(
            position = 1,
            mandatory = 0)]
        [string]
        $CollectorUri = "collectors",

        [parameter(
            position = 2,
            mandatory = 0)]
        [string]
        $RootUri = "https://api.sumologic.com/api/v1",

        [parameter(
            position = 3,
            mandatory = 1)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    try
    {
        if ($CollectorIds -eq $null)
        {
            $uri = $RootUri + "/" + $CollectorUri

            $Collectors = Invoke-RestMethod -Uri $uri -Method Get -Credential $Credential
            $Collectors.collectors
        }
        else
        {
            foreach ($CollectorId in $CollectorIds)
            {
                $uri = $RootUri + "/" + $CollectorUri + "/" + $CollectorId
                $Collectors = Invoke-RestMethod -Uri $uri -Method Get -Credential $Credential
                $Collectors.Collector
            }
        }
        
    }
    catch
    {
        throw $_
    }
}


function Remove-SumoApiCollectors{

    [CmdletBinding(
    )]
    param(
        [parameter(
            position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $CollectorIds,

        [parameter(
            position = 1,
            mandatory = 0)]
        [string]
        $CollectorUri = "collectors",

        [parameter(
            position = 2,
            mandatory = 0)]
        [string]
        $RootUri = "https://api.sumologic.com/api/v1",

        [parameter(
            position = 3,
            mandatory = 0)]
        [string]
        $uri = $RootUri + $CollectorUri,

        [parameter(
            position = 4,
            mandatory = 1)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    try
    {
        if ($CollectorIds -eq $null)
        {
            Write-Warning "CollectorIDs was null. Please input."
        }
        else
        {
            foreach ($CollectorId in $CollectorIds)
            {
                $uri = $RootUri + "/" + $CollectorUri + "/" + $CollectorId
                Write-Host "Posting Delete Request to $uri"
                Invoke-RestMethod -Uri $uri -Method Delete -Credential $Credential
            }
        }
    }
    catch
    {
        throw $_
    }
}



function Get-SumoApiCollectorsSource{

    [CmdletBinding(
    )]
    param(
        [parameter(
            position = 0,
            mandatory = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $SourceIds = $null,

        [parameter(
            position = 1,
            mandatory = 0)]
        [string]
        $sourceUri = "sources",

        [parameter(
            position = 2,
            mandatory = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $CollectorIds = $null,

        [parameter(
            position = 3,
            mandatory = 0)]
        [string]
        $CollectorUri = "collectors",

        [parameter(
            position = 4,
            mandatory = 0)]
        [string]
        $RootUri = "https://api.sumologic.com/api/v1",

        [parameter(
            position = 5,
            mandatory = 1)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    try
    {
        if ($CollectorIds -ne $null)
        {
            foreach ($CollectorId in $CollectorIds)
            {
                

                if ($SourceIds -eq $null)
                {
                    $uri = $RootUri + "/" + $CollectorUri + "/" + $CollectorId + "/" + $SourceUri
                    $Sources = Invoke-RestMethod -Uri $uri -Method Get -Credential $Credential
                }
                else
                {
                    foreach ($SourceId in $SourceIds)
                    {
                        $uri = $RootUri + "/" + $CollectorUri + "/" + $CollectorId + "/" + $SourceUri + "/" + $SourceId
                        $Sources = Invoke-RestMethod -Uri $uri -Method Get -Credential $Credential
                    }
                }

                $Sources.sources
            }
        }
    }
    catch
    {
        throw $_
    }
}





#-- Export Modules when loading this module --#

Export-ModuleMember `
    -Function * `
    -Alias * 
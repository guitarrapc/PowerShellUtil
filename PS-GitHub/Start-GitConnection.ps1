#Requires -Version 3.0

function Start-GitConnection{

    param(
    [ValidateSet($true,$false)]
    [bool]
    $quotepath=$false,

    [ValidateSet($true,$false)]
    [bool]
    $autoCRLF=$false,

    [ValidateSet("utf-8")]
    [string]
    $guiencording="utf-8",

    [bool]
    $ShowMan=$false,

    [string]
    $GitHomePath
    )

    New-ChocolateryInstall -ShowMan $ShowMan
    ""
    New-ChocolateryMsysgitInstall
    ""
    New-ChocolaterPoshGitInstall
    ""
    Set-EnvGitPath
    ""
    Set-EnvUserProfilePath
    ""
    Set-GitJapaneseEnv -quotepath $false -autoCRLF $False -guiencording utf-8
    ""
    Get-GitConfig
    ""
    Set-GitLocation
    
}
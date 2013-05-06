#Requires -Version 3.0

function Set-GitJapaneseEnv{

    param(
    
    [ValidateSet($true,$false)]
    [bool]
    $quotepath=$false,

    [ValidateSet($true,$false)]
    [bool]
    $autoCRLF=$false,

    [ValidateSet("utf-8")]
    [string]
    $guiencording="utf-8"
    )

    Write-Host "Setting git environment for Japanese."

    Write-Host "Setting quotepath as $quotepath" -ForegroundColor Green
    $quotepathConfig = Get-GitParameter -parameter "quotepath"
    if (!($quotepath -eq $quotepathConfig.value))
    {
        git config --global core.quotepath $quotepath
    }

    Write-Host "Setting autoCRLF as $autoCRLF" -ForegroundColor Green
    $autoCRLFConfig = Get-GitParameter -parameter "autoCRLF"
    if (!($autoCRLF -eq $autoCRLFConfig.value))
    {
        git config --global core.autoCRLF $autoCRLF
    }

    Write-Host "Setting guiencording as $guiencording" -ForegroundColor Green
    $guiencordingConfig = Get-GitParameter -parameter "guiencording"
    if (!($guiencording -eq $guiencordingConfig.value))
    {
        git config --global gui.encoding $guiencording
    }

}
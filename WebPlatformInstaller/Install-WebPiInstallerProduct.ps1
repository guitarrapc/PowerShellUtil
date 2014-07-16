function Install-WebPiInstallerProduct
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 0,
            Position  = 0,
            ValueFromPipeline = 1,
            ValueFromPipelineByPropertyName = 1)]
        [Microsoft.Web.PlatformInstaller.Product]
        $Product,

        [parameter(
            Mandatory = 0,
            Position  = 1,
            ValueFromPipelineByPropertyName = 1)]
        [ValidateSet(
            'en', 
            'de', 
            'es', 
            'fr', 
            'it', 
            'ja', 
            'ko', 
            'ru', 
            'zh-cn', 
            'zh-tw', 
            'zh-hk', 
            'cs', 
            'pl', 
            'tr', 
            'pt-br', 
            'he')]
        [string]
        $Language = [System.Globalization.CultureInfo]::CurrentCulture.TwoLetterISOLanguageName
    )

    process
    {
        # TODO : Context is Blank if Server module, like arrv3_0 was passed.
        $installer = New-Object 'System.Collections.Generic.List[Microsoft.Web.PlatformInstaller.Installer]'
        $installertouse = $product.GetInstaller($InstallLanguage)

        if ($null -ne $installertouse)
        {
            $installer.Add($installertouse)
            $InstallManager.Load($installer)

            # TODO : Installer Context not include installer path.
            foreach ($context in $InstallManager.InstallerContexts)
            {
                if ($null -ne $InstallManager.InstallerContexts.Installer.InstallerFile)
                {
                    $InstallManager.DownloadInstallerFile($context, [ref]$failureReason)
                }
                else
                {
                    Write-Error ("InstallerContext must include not Null InstallerFile to pass to Method DownloadInstallerFile().")
                }
            }
        }
        else
        {
            Write-Error ("Installer is blank, make sure your installation product contains language you selected. Product : '{0}', Language : '{1}'" -f $Product.ProductId, $Language)
        }
    }

    end
    {
        $InstallManager.StartInstallation()
    }

    begin
    {
        try
        {
            Add-Type -AssemblyName "Microsoft.Web.PlatformInstaller, Version=5.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
        }
        catch
        {
            # Glab and destroy
        }

        $InstallManager = New-Object Microsoft.Web.PlatformInstaller.InstallManager
        $InstallLanguage = $ProductManager.GetLanguage($Language)
        $failureReason = $null
    }
}
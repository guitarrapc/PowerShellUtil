function Get-WebPiInstallerProduct
{
    [CmdletBinding(DefaultParameterSetName = "IsApplication")]
    param
    (
        [parameter(
            Mandatory = 0,
            Position  = 0,
            ValueFromPipeline = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string[]]
        $ProductId,

        [parameter(
            Mandatory = 0,
            Position  = 1,
            ValueFromPipelineByPropertyName = 1)]
        [ValidateSet(
            'AppFrameworks',
            'ASPNET',
            'ASPNET4',
            'AzureReady',
            'Blogs',
            'ContentMgmt',
            'Database',
            'eCommerce',
            'Forums',
            'FrameworkRuntime',
            'Galleries',
            'KatalReady',
            'Lightswitch',
            'MySQL',
            'Office',
            'PHP',
            'ProductSpotlight',
            'ProductTools',
            'Server',
            'Sharepoint',
            'SQL',
            'SQLCE',
            'Tools',
            'Wiki',
            'WindowsAzure')]
        [string]
        $KeywordId = "",

        [parameter(
            Mandatory = 0,
            Position  = 2,
            ParameterSetName = "IsApplication")]
        [bool]
        $IsApplication = $false,

        [parameter(
            Mandatory = 0,
            Position  = 2,
            ParameterSetName = "IsComponent")]
        [bool]
        $IsIisComponent = $false,

        [parameter(
            Mandatory = 0,
            Position  = 2,
            ParameterSetName = "IsExternal")]
        [bool]
        $IsExternal = $false
    )

    process
    {
        if ($PSBoundParameters.ContainsKey('ProductId'))
        {
            foreach ($x in $ProductId)
            {
                $result = $KeywordProduct | where ProductId -like $x
                $list.Add($result)
            }
        }
        else
        {
            $list = $KeywordProduct
        }
    }

    end
    {
        return $list
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

        $ProductManager = New-Object Microsoft.Web.PlatformInstaller.ProductManager
        $list = New-Object 'System.Collections.Generic.List[Microsoft.Web.PlatformInstaller.Product]'

        $ProductManager.Load()
        $product = switch ($true)
        {
            $IsApplication  {$ProductManager.Products | where IsApplication}
            $IsIisComponent {$ProductManager.Products | where IsIisComponent}
            $IsExternal     {$ProductManager.Products | where External}
            default         {$ProductManager.Products}
        }
        
        $KeywordProduct = if ($KeywordId -ne "")
        {
            $product | where {$_.Keywords.Id -like $KeywordId}
        }
        else
        {
            $product
        }
    }
}
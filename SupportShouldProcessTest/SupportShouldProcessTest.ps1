function hoge{
[CmdletBinding(SupportsShouldProcess)]
param(
    [parameter(ValueFromPipeline)]
    $path,
    $destination,
    [switch]$force
)

begin
{
    $PSBoundParameters.Remove('Force') > $null
    $PSBoundParameters.Confirm = $false
}
process{
    #if ($force -or $PSCmdlet.ShouldProcess($path,"copy to $destination"))
    if ($force -or $PSCmdlet.ShouldProcess($Confirm,"copy to $destination"))
    {      
        Copy-Item @PSBoundParameters
    }

    
}

}

ls .\*.ps1 | hoge -destination test -Confirm
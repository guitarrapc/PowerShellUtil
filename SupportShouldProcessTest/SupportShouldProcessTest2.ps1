function Test-ShouldProcessEx {            
[CmdletBinding(            
    SupportsShouldProcess = $true            
)]            
param (            
    [Parameter(            
        ValueFromPipeline = $true            
    )]            
    [string]$Path,            
    [string]$Destination,            
    [switch]$Force            
)            
            
begin {            
    $PSBoundParameters.Remove('Force') | Out-Null            
    $PSBoundParameters.Confirm = $false            
}            
            
process {            
    if ($Force -or $PSCmdlet.ShouldProcess(            
        $Path,             
        "Move to $Destination"            
    )) {            
        Copy-Item @PSBoundParameters            
    }            
}            
}            

ls .\*.ps1 | Test-ShouldProcessEx -Destination test -Confirm
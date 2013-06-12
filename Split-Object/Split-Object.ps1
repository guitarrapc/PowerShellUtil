function Split-Object{
 
    [CmdletBinding(  
        SupportsShouldProcess = $false,
        ConfirmImpact = "none",
        DefaultParameterSetName = ""
    )]
 
    param
    (
        [Parameter(
        HelpMessage = "Input Object you want to split",
        Position = 0,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        #[ValidateNotNullOrEmpty()]
		[object[]]
        $Item,

        [Parameter(
        HelpMessage = "Input Number you want to split each",
        Position = 0,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
		[int]
        $GroupNumber
    )
 
    begin
    {
		$skipcount = [math]::Truncate($Item.count / $GroupNumber)
    }
 
    process
    {
			
		0..$skipcount | %{
		    $Item | Select-Object -skip $($GroupNumber * $_) -First $GroupNumber
		# {Set command you want to do...}
		}
    }
 
    end
    {
    }
}

Split-Object -Item $(ps | sort WS -Descending) -GroupNumber 20 

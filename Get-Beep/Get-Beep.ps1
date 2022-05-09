filter Get-Beep {
	param(
	[Parameter(ValueFromPipeline=$true)]
	    [int[]]$keyNote
	)

	[console]::Beep($keyNote[0],$keyNote[1])
}

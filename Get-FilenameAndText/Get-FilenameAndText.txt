Get-ChildItem ./*.log | %{ $fname=$_.name; $read=cat $_; [PSCustomObject]@{file=$fname;read="$read"} | Export-Csv ./ListofFiles.csv -NoClobber -Append}



Get-ChildItem ./*.log `
	| %{ 
		$fname=$_.name
		$read=cat $_
		[PSCustomObject]@{
			file=$fname
			read="$read"
		} `
	| Export-Csv ./ListofFiles.csv -NoClobber -Append
}

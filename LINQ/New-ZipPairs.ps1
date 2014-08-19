function New-ZipPairs
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 1,
            Position = 0,
            ValueFromPipelineByPropertyName = 1)]
        [string[]]
        $key,
 
        [parameter(
            Mandatory = 1,
            Position = 1,
            ValueFromPipelineByPropertyName = 1)]
        [string[]]
        $value,
 
        [parameter(
            Mandatory = 0,
            Position = 2)]
        [string]
        $Prefix = "_"
    )
 
    begin
    {
        function ToArrayEx ([string[]]$InputStringArray)
        {
            $array = @()
            $array += $InputStringArray | %{$_}
            $array
        }

        $list = New-Object 'System.Collections.Generic.List[System.Tuple[string, string]]'
    }
 
    process
    {
        # ToArray
        [string[]]$keys = ToArrayEx -InputStringArray $key
        [string[]]$values = ToArrayEx -InputStringArray $value
 
        # Element Count Check
        $keyElementsCount = ($keys | measure).count
        $valueElementsCount = ($values | measure).count
        if ($valueElementsCount -eq 0)
        {
            # TagValue auto fill with "*" when Value is empty
            $values = 1..$keyElementsCount | %{"*"}
        }
 
        # Get shorter list
        $length = if ($keyElementsCount -le $valueElementsCount)
        {
            $keyElementsCount
        }
        else
        {
            $valueElementsCount
        }
 
        # Make Element Pair
        $i = 0
        do
        {
            $list.Add($(New-Object 'System.Tuple[[string],[string]]' ($keys[$i], $values[$i])))
            $i++
        }
        while ($i -lt $length)
    }
 
    end
    {
        return $list
    }
}

# NewZipPairs -key 1, 2, 3, 4 -value hoge, moge, fuga, piyo
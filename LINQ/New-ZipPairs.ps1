function New-ZipPairs
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 1,
            Position = 0,
            ValueFromPipelineByPropertyName = 1)]
        $key,
 
        [parameter(
            Mandatory = 1,
            Position = 1,
            ValueFromPipelineByPropertyName = 1)]
        $value
     )
 
    begin
    {
        if ($null -eq $key)
        {
            throw "Key Null Reference Exception!!"
        }

        if ($null -eq $value)
        {
            throw "Value Null Reference Exception!!"
        }

        function ToListEx ($InputArray, $type)
        {
            $list = New-Object "System.Collections.Generic.List[$type]"
            @($InputArray) | where {$_.GetType().FullName -eq $type} | %{$list.Add($_)}
            return $list
        }

        function GetType ($Object)
        {
            @($Object) | select -First 1 | %{$_.GetType().FullName}
        }
    }
 
    process
    {
        # Get Type
        $keyType = GetType -Object $key
        $valueType = GetType -Object $value

        # Create Typed container
        $list = New-Object "System.Collections.Generic.List[System.Tuple[$keyType, $valueType]]"

        # To Typed List
        $keys = ToListEx -InputArray $key -type $keyType
        $values = ToListEx -InputArray $value -type $valueType
 
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
        if ($length -eq 1)
        {
            $list.Add($(New-Object "System.Tuple[[$keyType],[$valueType]]" ($keys, $values)))
        }
        else
        {
            $i = 0
            do
            {
                $list.Add($(New-Object "System.Tuple[[$keyType],[$valueType]]" ($keys[$i], $values[$i])))
                $i++
            }
            while ($i -lt $length)
        }
    }
 
    end
    {
        return $list
    }
}

<#
# sample Key<String>, Value<Int32>
[int[]]$hoge = 1, 2, 3, 4
[string[]]$fuga = "hoge", "moge", "fuga", "piyo"
New-ZipPairs -key $hoge -value $fuga
#>

# sample Key<System.Diagnostics.Process>, Value<System.IO.FileInfo>
# New-ZipPairs -key (ps) -value (ls)

# sample single item input
# New-ZipPairs -key "d:\hogemoge" -value "d:\fugafuga"

<#
# sample Key<String>, Value<Int32>
[int[]]$hoge = 1
[string[]]$fuga = "hoge"
New-ZipPairs -key $hoge -value $fuga
#>
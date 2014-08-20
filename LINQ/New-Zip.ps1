function New-Zip
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 0,
            Position = 0,
            ValueFromPipelineByPropertyName = 1)]
        $first,
 
        [parameter(
            Mandatory = 0,
            Position = 1,
            ValueFromPipelineByPropertyName = 1)]
        $second
    )

    process
    {
        if ([string]::IsNullOrWhiteSpace($first)){ break }        
        if ([string]::IsNullOrWhiteSpace($second)){ break }

        # Get Type
        $keyType = GetType -Element $first
        $valueType = GetType -Element $second

        # Initialize List
        $list = New-Object "System.Collections.Generic.List[System.Tuple[$keyType, $valueType]]"

        # Get Typed element
        $e1 = @(ToListEx -InputElement $first -type $keyType).GetEnumerator()
        $e2 = @(ToListEx -InputElement $second -type $valueType).GetEnumerator()

        try
        {
            while ($e1.MoveNext() -and $e2.MoveNext())
            {
                $e1Current = TakeTypedElement -InputElement $e1.Current -type $keyType
                $e2Current = TakeTypedElement -InputElement $e2.Current -type $valueType
                $list.Add($(New-Object "System.Tuple[[$keyType],[$valueType]]" ($e1Current, $e2Current)));
            }
        }
        finally
        {
            $d1 = $e1 -as [IDisposable]
            $d2 = $e1 -as [IDisposable]
            if($d1 -ne $null) { $d1.Dispose() }
            if($d2 -ne $null) { $d2.Dispose() }
        }
    }

    end
    {
        return $list
    }

    begin
    {
        function GetType ($Element)
        {
            $e = @($Element).GetEnumerator()
            $e.MoveNext() > $null
            $e.Current.GetType().FullName
        }

        function TakeTypedElement ($InputElement, $type)
        {
            @($InputElement) | where {$_.GetType().FullName -eq $type}
        }

        function ToListEx ($InputElement, $type)
        {
            $list = New-Object "System.Collections.Generic.List[$type]"
            @($InputElement) | where {$_.GetType().FullName -eq $type} | %{$list.Add($_)}
            return @($list)
        }
    }
}

<#
$first = 1, 2,3
$second = 5, 6,7, 10
New-Zip -first $first -second $second

$first = ps
$second = ls
New-Zip -first $first -second $second

$first = 1, 2, 3, 4
$second = "hoge", "moge", "fuga", "piyo"
New-Zip -first $first -second $second

$first = 1
$second = "hoge", "fuga"
New-Zip -first $first -second $second

$first = ""
$second = "hoge"
New-Zip -first $first -second $second
#>
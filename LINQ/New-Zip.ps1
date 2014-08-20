function New-Zip
{
    [CmdletBinding()]
    param
    (
        [parameter(
            Mandatory = 0,
            Position = 0,
            ValueFromPipeline = 1,
            ValueFromPipelineByPropertyName = 1)]
        [PSObject[]]
        $first,
 
        [parameter(
            Mandatory = 0,
            Position = 1,
            ValueFromPipelineByPropertyName = 1)]
        [PSObject[]]
        $second,

        [parameter(
            Mandatory = 0,
            Position = 2,
            ValueFromPipelineByPropertyName = 1)]
        [scriptBlock]
        $resultSelector
    )

    process
    {
        if ([string]::IsNullOrWhiteSpace($first)){ break }        
        if ([string]::IsNullOrWhiteSpace($second)){ break }
        
        try
        {
            $e1 = @($first).GetEnumerator()

            while ($e1.MoveNext() -and $e2.MoveNext())
            {
                if ($PSBoundParameters.ContainsKey('resultSelector'))
                {
                    $first = $e1.Current
                    $second = $e2.Current
                    $context = $resultselector.InvokeWithContext(
                        $null,
                        ($psvariable),
                        {
                            (New-Object System.Management.Automation.PSVariable ("first", $first)),
                            (New-Object System.Management.Automation.PSVariable ("second", $second))
                        }
                    )
                    $context
                }
                else
                {
                    $tuple = New-Object 'System.Tuple[PSObject, PSObject]' ($e1.Current, $e2.current)
                    $tuple
                }
            }
        }
        finally
        {
            if(($d1 = $e1 -as [IDisposable]) -ne $null) { $d1.Dispose() }
            if(($d2 = $e1 -as [IDisposable]) -ne $null) { $d2.Dispose() }
            if(($d3 = $psvariable -as [IDisposable]) -ne $null) {$d3.Dispose() }
            if(($d4 = $context -as [IDisposable]) -ne $null) {$d4.Dispose() }
            if(($d5 = $tuple -as [IDisposable]) -ne $null) {$d5.Dispose() }
        }
    }

    begin
    {
        $e2 = @($second).GetEnumerator()
        $psvariable = New-Object 'System.Collections.Generic.List[PSVariable]]'
    }
}

<#
$first = 1, 2,3
$second = 5, 6,7, 10
New-Zip -first $first -second $second -resultSelector {"$first : $second"}

$first = ps
$second = ls
New-Zip -first $first -second $second -resultSelector {"$first : $second"}

$first = 1, 2, 3, 4
$second = "hoge", "moge", "fuga", "piyo"
New-Zip -first $first -second $second -resultSelector {"$first : $second"}

$first = 1
$second = "hoge", "fuga"
New-Zip -first $first -second $second -resultSelector {"$first : $second"}

$first = ""
$second = "hoge"
New-Zip -first $first -second $second -resultSelector {"$first : $second"}

$first = 1..10
$second = 100..3
$first | New-zip -second $second -resultSelector {"$first : $second"}


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

$first = 1..10
$second = 100..3
$first | New-zip -second $second
#>

<#
# Basic Thinking

function hoge 
{
    param(
        [parameter(valuefromPipeline)]
        [PSObject]
        $hoge, 
        [PSObject[]]
        $fuga
    )
    begin
    {
        $e2 = @($fuga).GetEnumerator()
    }
    process
    {
        $e2.MoveNext() > $null
        $hoge
        $e2.current | gm
    }
}

1..10 | hoge -fuga (10..1)
#>
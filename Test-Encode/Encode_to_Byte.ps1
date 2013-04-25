$string = "za\u0306\u01FD\u03B2\uD8FF\uDCFF"

$utf7 = [System.Text.Encoding]::UTF7
$utf8 = [System.Text.Encoding]::UTF8
$utf16LE = [System.Text.Encoding]::Unicode
$utf16BE = [System.Text.Encoding]::BigEndianUnicode
$utf32 = [System.Text.Encoding]::UTF32
$default = [System.Text.Encoding]::Default


function Get-PrintCountsAndBytes {
    param(
    [string]$string,
    [System.Text.Encoding]$encording
    )
    
     [System.Console]::Write("{0,-30}:" -f $encording.ToString())
    
    $iBC = $encording.GetByteCount($string)
    [System.Console]::Write("{0,-3}:" -f [convert]::ToString($iBC,16))

    $iMBC = $encording.GetMaxByteCount($string.Length)
    [System.Console]::Write("{0,-3}:" -f [convert]::ToString($iMBC,16))
    
    [byte[]]$bytes = $encording.GetBytes($string)

    [System.Console]::Write((Get-PrintHexBytes($bytes)))
    ""
}

function Get-PrintCountsAndBytesByIndex {
    param(
    [string]$string,
    [int]$index,
    [int]$count,
    [System.Text.Encoding]$encording
    )
    
     [System.Console]::Write("{0,-30}:" -f $encording.ToString())
    
    $iBC = $encording.GetByteCount($string.ToCharArray(),$index,$count)
    [System.Console]::Write("{0,-3}:" -f [convert]::ToString($iBC,16))

    $iMBC = $encording.GetMaxByteCount($count)
    [System.Console]::Write("{0,-3}:" -f [convert]::ToString($iMBC,16))
    
    #[byte[]]$bytes = $iBC
    [byte[]]$bytes = $string.ToCharArray()
    $bytes = $encording.GetBytes($string, $index, $count, $bytes, $bytes.GetLowerBound(0))
    #[byte[]]$bytes = $encording.GetBytes($string,$index,$count)

    [System.Console]::Write((Get-PrintHexBytes($bytes)))
    ""
}


function Get-PrintHexBytes{

    param(
    [byte[]]$bytes
    )

    if(($null -eq $bytes) -or $bytes.length -eq 0)
    {
        "<none>"
    }
    else
    {
        for($i =0; $i -lt $bytes.length; $i++)
        {
            [System.Console]::Write("{0:X2} " -f [convert]::ToString($bytes[$i],16))
        }
    }

}

Get-PrintCountsAndBytes -encording $utf7 -string $string
Get-PrintCountsAndBytes -encording $utf8 -string $string
Get-PrintCountsAndBytes -encording $utf16LE -string $string
Get-PrintCountsAndBytes -encording $utf16BE -string $string
Get-PrintCountsAndBytes -encording $utf32 -string $string
Get-PrintCountsAndBytes -encording $default -string $string
""    
Get-PrintCountsAndBytesByIndex -encording $utf7 -string $string -index 4 -count 3
Get-PrintCountsAndBytesByIndex -encording $utf8 -string $string -index 4 -count 3
Get-PrintCountsAndBytesByIndex -encording $utf16LE -string $string -index 4 -count 3
Get-PrintCountsAndBytesByIndex -encording $utf16BE -string $string -index 4 -count 3
Get-PrintCountsAndBytesByIndex -encording $utf32 -string $string -index 4 -count 3
Get-PrintCountsAndBytesByIndex -encording $default -string $string -index 4 -count 3


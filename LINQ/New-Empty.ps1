function New-Empty ([string]$type)
{
$def = @"
public static System.Collections.Generic.IEnumerable<$type> Empty()
{
    System.Collections.Generic.IEnumerable<$type> empty = System.Linq.Enumerable.Empty<$type>();
    return empty;
}
"@
    try
    {
        $name = [guid]::NewGuid().Guid -replace '-',''
        $empty = Add-Type -MemberDefinition $def -name $name -passThru
        return @($empty::Empty())
    }
    catch
    {
    }
}

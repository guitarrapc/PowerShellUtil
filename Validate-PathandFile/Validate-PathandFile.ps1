$invalidfilename = [System.IO.Path]::GetInvalidFileNameChars()
$invalidchar = [System.Text.RegularExpressions.Regex]::Escape($invalidfile)

$invalidpath = [System.IO.Path]::GetInvalidPathChars()
$target = "c:\asdfa\asdfadf\sdf//g.txt"

$target = "c:\teho\::::\sdfg^#%&'!<>.txt"
$target.IndexOfAny($invalidfile)

$target.IndexOfAny($invalidpath)

if (Test-Path $target -IsValid)
{
    1
}
else
{
    0
}

$target = "mew<>.txt"
$target.IndexOfAny($invalidfile)
$target 

if ($target.IndexOfAny($invalid))
{
    1
}
else
{
    0
}



$names = Select-String -Path D:\newnames.txt -Pattern "\W" | select -ExpandProperty Line
$targetpath = 'D:\hoge'

Get-ChildItem -Path $targetpath `
    | %{ 
        # get original extention
        $extention = $_.Extension

        # get matching names
        [string]$matchingname = $names -like "*$($_.Name.Substring(0,2))*"

        # configure new name
        $newname = [System.IO.Path]::ChangeExtension($matchingname.Replace(" ",""),$extention)

        # rename items
        if ($matchingname)
        {
            Rename-Item -Path $_.FullName -NewName $newname
        }
    }
# Get invalid charactors for filename
$invalidfilename = [System.IO.Path]::GetInvalidFileNameChars()

# Get names from namelist
$namelist = "D:\newnames.txt"
$names = Select-String -Path $namelist -Pattern "\W" | select -ExpandProperty Line

# get filenames from targetpath
$targetpath = 'D:\hoge'
Get-ChildItem -Path $targetpath `
    | %{ 
        # get original extention
        $extention = $_.Extension

        # get matching names
        [string]$matchingname = $names -like "*$($_.Name.Substring(0,2))*"

        if ($matchingname)
        {
            # get index of validation (valid = -1)
            $validationIndex = $matchingname.IndexOfAny($invalidpath)

            # execute rename
            if ($validationIndex -eq "-1")
            {
                # configure new name
                $newname = [System.IO.Path]::ChangeExtension($matchingname.Replace(" ",""),$extention)

                # rename item
                Write-Warning -Message ("running rename with {0} to {1}" -f $_.FullName, $newname)
                Rename-Item -Path $_.FullName -NewName $newname
            }
            else
            {
                Write-Error -Message ("{0} contains invalid charactor. index : {1}" -f $matchingname, $validationIndex)
            }
        }
    }
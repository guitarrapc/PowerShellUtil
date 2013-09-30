function Add-Zip{

    [CmdletBinding()]
	param(
        [parameter(
            mandatory,
            position = 0,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string[]]
        $inputfile,

        [parameter(
            mandatory,
            position = 1,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [validatescript({[System.IO.Path]::GetExtension($_) -eq ".zip"})]
        [string]
        $zipfilename,

        [parameter(
            mandatory = 0,
            position = 2,
            valuefrompipeline,
            valuefrompipelinebypropertyname)]
        [string]
        $zipfilefolder = $null
    )

    $ErrorActionPreference = "Continue"

    foreach ($item in $inputfile)
    {
        if ((Get-Item $item).PSIsContainer)
        {
            [System.IO.FileInfo[]]$files = Get-ChildItem $item
        }
        else
        {
            [System.IO.FileInfo]$files = Get-Item $item
        }

        foreach ($f in $files)
        {
            if (Test-Path -Path $f.FullName)
            {
                # set zip folder if null
                if (-not($zipfilefolder))
                {
                    $zipfilefolder = (Get-ChildItem $f).DirectoryName
                }

                # create zip folder
                if (-not(Test-Path $zipfilefolder))
                {
                    New-Item -Path $zipfilefolder -ItemType Directory -Force
                }

                # create zip path
                $zippath = Join-Path $zipfilefolder $zipfilename

                # create zip
	            if(-not(Test-Path $zippath))
	            {
                    Write-Verbose ("Creating zip file {0}" -f $zippath)

		            Set-Content $zippath ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
                    (Get-Item $zippath).IsReadOnly = $false
	            }

                # Initialize zip
	            $shellApplication = New-Object -ComObject Shell.Application
	            $zipPackage = $shellApplication.NameSpace($zippath)

                # copy items to zip
                if($f.fullname -ne $zippath)
                {
                    Write-Verbose ("copying item {0} to {1}" -f $f.fullname, $zippath)
                    $zipPackage.CopyHere($f.FullName)
                }
                else
                {
                    Write-Verbose ("source item {0} was same as zipfile {1}. skip to next." -f $f.fullname, $zippath)
                }
                sleep -milliseconds 500	
            }
            else
            {
                Write-Warning ("{0} not found. skip to next." -f $f)
            }
        }
    }
}

Add-Zip -inputfile ("c:\test",".\test", ".\test") -zipfilename hoge.zip -Verbose
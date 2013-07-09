#Requires -Version 3.0

function Invoke-DownloadFile{

    [CmdletBinding()]
    param(
        [parameter(Mandatory,position=0)]
        [string]
        $Uri,

        [parameter(Mandatory,position=1)]
        [string]
        $DownloadFolder,

        [parameter(Mandatory,position=2)]
        [string]
        $FileName
    )

    begin
    {
        If (-not(Test-Path $DownloadFolder))
        {
            try
            {
                New-Item -ItemType Directory -Path $DownloadFolder -ErrorAction stop
            }
            catch
            {
                throw $_
            }
        }

        try
        {
            $DownloadPath = Join-Path $DownloadFolder $FileName -ErrorAction Stop
        }
        catch
        {
            throw $_
        }
    }

    process
    {
        Invoke-WebRequest -Uri $Uri -OutFile $DownloadPath -Verbose -PassThru
    }

    end
    {
        Get-Item $DownloadPath
    }

}

Invoke-DownloadFile -Uri "https://collectors.sumologic.com/rest/download/windows" -DownloadFolder "D:\hoge" -FileName "SumoCollector_WindowsSetup.exe"
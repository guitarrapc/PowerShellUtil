configuration UnZipFile {

    param (
        [Parameter(mandatory)]
        [string[]]$ComputerName,
        [string]$Path,
        [string]$Destination
    )
    
    node $ComputerName {
        archive ZipFile {
        Path = $Path
        Destination = $Destination
        Ensure = 'Present'
        }
    }
}

UnZipFile -ComputerName localhost -Path D:\hoge.zip -Destination d:\hogehoge -Verbose
Start-DscConfiguration -Path .\UnZipFile -Wait -Force -Verbose
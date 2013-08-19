function touch{
    [CmdletBinding()]
    param(
        [parameter(
        position = 0,
        mandatory = 1,
        ValueFromPipeline = 1,
        ValueFromPipelineByPropertyName = 1
        )]
        [string]$path,

        [parameter(
        position = 1,
        mandatory = 0,
        ValueFromPipeline = 1,
        ValueFromPipelineByPropertyName = 1
        )]
        [datetime]$date = $(Get-Date),

        [parameter(
        position = 2,
        mandatory = 0,
        HelpMessage = "Change Last AccessTime only"
        )]
        [switch]$access,

        [parameter(
        position = 3,
        mandatory = 0,
        HelpMessage = "Do not create file if not exist"
        )]
        [switch]$nocreate,

        [parameter(
        position = 4,
        mandatory = 0,
        HelpMessage = "Change Last WriteTime only"
        )]
        [switch]$modify,

        [parameter(
        position = 5,
        mandatory = 0,
        HelpMessage = "LastAccessTime reference file"
        )]
        [string]$reference
    )

    if (-not(Test-Path $path))
    {
        if ((!$nocreate))
        {
            New-Item -Path $path -ItemType file -Force
        }
    }
    else
    {
        try
        {
            if ($reference)
            {
                $date = (Get-ItemProperty -Path $reference).LastAccessTime
            }

            if ($access)
            {
                Get-ChildItem $path | %{Set-ItemProperty -path $_.FullName -Name LastAccessTime -Value $date -Force -ErrorAction Stop}
            }
        
            if ($modify)
            {
                Get-ChildItem $path | %{Set-ItemProperty -path $_.FullName -Name LastWriteTime -Value $date -Force -ErrorAction Stop}
            }

            if (!$access -and !$modify)
            {
                Get-ChildItem $path | %{Set-ItemProperty -path $_.FullName -Name LastAccessTime -Value $date -Force -ErrorAction Stop}
                Get-ChildItem $path | %{Set-ItemProperty -path $_.FullName -Name LastWriteTime -Value $date -Force -ErrorAction Stop}
            }
        }
        catch
        {
            throw $_
        }
        finally
        {
            Get-ChildItem $path | %{Get-ItemProperty -Path $_.FullName | select Fullname, LastAccessTime, LastWriteTime}
        }
    }    

}

#touch -path d:\test\hogefuga.log -nocreate
#touch -path d:\test\hogefuga.log
#touch -path d:\test\hoge.log -modify -access 
#touch -path d:\test\hoge.log -modify | ft -au
#touch -path d:\test\hoge.log -access　| ft -au
#touch -path d:\test\hoge.log -modify -access -reference C:\bootmgr | ft -aut
#touch -path d:\test\* -modify -access -reference C:\bootmgr | ft -aut
function Get-FileHashIndex
{
<#
.Synopsis
   Get File Hash for PowerShell V3 and Higher
.DESCRIPTION
   Bringed C# how we retrieve File Hash to PowerShell Script.
   This works equivalent to Get-FileHash (v4) but twice as faster and supports -Recurse switch.

    measure-Command {Get-FileHashIndex -Path d:\test\test -Algorithm MACTripleDES -Recurse} # 684.4821
    measure-Command {Get-FileHashIndex -Path d:\test\test -Algorithm MD5 -Recurse} # 631.5687
    measure-Command {Get-FileHashIndex -Path d:\test\test -Algorithm RIPEMD160 -Recurse} # 693.6726
    measure-Command {Get-FileHashIndex -Path d:\test\test -Algorithm SHA1 -Recurse} # 641.9092
    measure-Command {Get-FileHashIndex -Path d:\test\test -Algorithm SHA256 -Recurse} # 695.2601
    measure-Command {Get-FileHashIndex -Path d:\test\test -Algorithm SHA384 -Recurse} # 677.8795
    measure-Command {Get-FileHashIndex -Path d:\test\test -Algorithm SHA512 -Recurse} # 685.4792
    measure-Command {ls d:\test\test -Recurse -File | Get-FileHashIndex -Algorithm MD5} # 878.1032
    measure-Command {ls d:\test\test -Recurse -File | Get-FileHash -Algorithm MD5} # 1364.2046
    measure-Command {ls d:\test\test -Recurse -File | Get-FileHash -Algorithm SHA256} # 1488.3237

.EXAMPLE
    PS > Get-FileHashIndex -Path d:\test\test -Algorithm MACTripleDES -Recurse

    Algorythm                                 Hash                                      Path
    ---------                                 ----                                      ----
    MACTripleDES                              40C3FEAAA71C928B2FC3D248F4DA86211FBC1726  D:\test\test\README.md
    MACTripleDES                              5DCE5F942594C97A9929D18507FB043FC23B917B  D:\test\test\hoge\Thumbs.db

.EXAMPLE
    PS > Get-FileHashIndex -Path d:\test\test -Algorithm MACTripleDES

    Algorythm                                 Hash                                      Path
    ---------                                 ----                                      ----
    MACTripleDES                              40C3FEAAA71C928B2FC3D248F4DA86211FBC1726  D:\test\test\README.md

.EXAMPLE
    PS > Get-FileHashIndex -Path d:\test\test -Algorithm MD5

    Algorythm                                 Hash                                      Path
    ---------                                 ----                                      ----
    MD5                                       7C865A164CE6DFC4AE0E61EED9A49B8E          D:\test\test\README.md

.EXAMPLE
    PS > Get-FileHashIndex -Path d:\test\test -Algorithm RIPEMD160

    Algorythm                                 Hash                                      Path
    ---------                                 ----                                      ----
    RIPEMD160                                 92DD18916AA074B0931E63D14541C44F07783CDF  D:\test\test\README.md

.EXAMPLE
    PS > Get-FileHashIndex -Path d:\test\test -Algorithm SHA1

    Algorythm                                 Hash                                      Path
    ---------                                 ----                                      ----
    SHA1                                      73A0294775D3A91F1EC91EEF58AD28C48A5B515A  D:\test\test\README.md

.EXAMPLE
    PS > Get-FileHashIndex -Path d:\test\test -Algorithm SHA256

    Algorythm                                 Hash                                      Path
    ---------                                 ----                                      ----
    SHA256                                    50DB8AFF8EFE10C9CBAAA2BE941E841AFF5ECC... D:\test\test\README.md

.EXAMPLE
    PS > Get-FileHashIndex -Path d:\test\test -Algorithm SHA384

    Algorythm                                 Hash                                      Path
    ---------                                 ----                                      ----
    SHA384                                    A8E66530035B84816C4C8BD2D4E17CC00D5848... D:\test\test\README.md

.EXAMPLE
    PS > Get-FileHashIndex -Path d:\test\test -Algorithm SHA512

    Algorythm                                 Hash                                      Path
    ---------                                 ----                                      ----
    SHA512                                    13A29B1D0C28ED69B441481282B3983F729D51... D:\test\test\README.md

.OUTPUTS
   [PSCustomObject]
   
   Incluide Algorithm, Hash and Path Property
#>

    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 1, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName =1)]
        [Alias("PSPath", "LiteralPath")]
        [string[]]$Path,

        [parameter(Mandatory = 0, Position = 1, ValueFromPipelineByPropertyName =1, ParameterSetName = "MD5")]
        [ValidateSet("MACTripleDES", "MD5", "RIPEMD160", "SHA1", "SHA256", "SHA384", "SHA512")]
        [string]$Algorithm = "MD5",

        [parameter(Mandatory = 0, Position = 2, ValueFromPipelineByPropertyName =1)]
        [switch]$Recurse
    )

    process
    {
        foreach ($p in $Path){ $list.Add($p) }
    }

    end
    {        
        Get-ChildItem -Path $list -Recurse:$Recurse -File `
        | %{
            try
            {
                [System.IO.FileStream]$stream = [System.IO.File]::OpenRead($_.fullname)
                $hash = GetHash -Stream $stream -Algorithm $Algorithm
            }
            finally
            {
                $stream.Dispose()
            }

            return [PSCustomObject]@{
                Algorythm = $Algorithm
                Hash = $hash
                Path = $_.FullName
            }
        }
    }

    begin
    {
        $list = New-Object 'System.Collections.Generic.List[string]'
        function GetHash ([System.IO.FileStream]$Stream, [string]$Algorithm)
        {
            try
            {
                $crypto = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm)
                [byte[]]$hash = $crypto.ComputeHash($Stream)
                return [System.BitConverter]::ToString($hash).Replace("-", [string]::Empty)
            }
            finally
            {
                $crypto.Dispose()
            }
        }

    }
}
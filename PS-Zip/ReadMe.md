# ReadMe

## Change History

以前と変わっていませんが、いくつか追加しています。

1. パラメータとして、```-force```スイッチを付け加えています。
2. 単独ファイルだけでなく、ワイルドカード(*)での複数ファイル指定、サブディレクトリを含むフォルダにも対応しています。
3. 圧縮、解凍ともに```-destination``` パラメータは必須ではないようにし、指定されなかった場合は デスクトップに生成するようにしています。


## How to use code Sample

## Compress

```Powershell
# Compres Sample
New-ZipCompression -source D:\test -destination d:\hoge.zip

# 出力結果が true/falseのみとなる
New-ZipCompression -source D:\test -destination d:\hoge.zip -quiet

# デスクトップに、sourceに指定したフォルダ名でzipを生成
New-ZipCompression -source D:\test

# デスクトップに、sourceに指定したファイルを名称としてzipを生成
New-ZipCompression -source D:\test\hoge.ps1

# デスクトップに、sourceに指定したファイルの先頭を名称としてzipを生成
New-ZipCompression -source D:\test\*.ps1

# destinationが重複していた場合、削除するか聞いてきます(Nで消さないと例外)
New-ZipCompression -source D:\test\*.ps1

# -forceを付けることで、たとえdestinationが重複していた場合に削除しなくても、自動的に連番を付けてzip圧縮します。
New-ZipCompression -source D:\test\*.ps1 -force
```

## Extract

```Powershell
# Extract Sample
New-ZipExtract -source d:\hoge.zip -destination d:\hogehoge

# 出力結果が true/falseのみとなる
New-ZipExtract -source d:\hoge.zip -destination d:\hogehoge -quiet

# デスクトップに、sourceに指定したzip名でフォルダを生成
New-ZipExtract -source D:\hoge.zip

# destinationが重複していた場合、削除するか聞いてきます(Nで消さないと例外)
New-ZipExtract -source D:\test\hoge.zip

# -forceを付けることで、たとえdestinationが重複していた場合に削除しなくても、自動的に連番を付けてzip圧縮します。
New-ZipExtract -source D:\test\hoge.ps1 -force
```

# Test Passed

This module checkes with following test.

#### Condition

```PowerShell
PS D:\> Get-ChildItem D:\hoge
```

result :

```text
    Directory: D:\hoge


Mode         LastWriteTime Length Name       
----         ------------- ------ ----       
d---- 2013/10/08     16:59        Ori        
-a--- 2013/10/07      8:38    489 dsc-zip.ps1
-a--- 2013/09/26      5:00     40 test.ps1   
-a--- 2013/10/07      9:39     40 test2.ps1  
```

#### Compres Test

```PowerShell
$ErrorActionPreference = "stop"

try
{
    1
    New-ZipCompress -source D:\hoge -destination d:\hoge.zip -verbose
    2
    New-ZipCompress -source D:\hoge -verbose
    3
    New-ZipCompress -source D:\hoge -force -verbose
    4
    New-ZipCompress -source D:\hoge -safe -verbose
    5
    New-ZipCompress -source D:\hoge\ -quiet -verbose
    6
    New-ZipCompress -source D:\hoge\* -destination d:\hoge.zip -verbose
    7
    New-ZipCompress -source D:\hoge\* -verbose
    8
    New-ZipCompress -source D:\hoge\* -force -verbose
    9
    New-ZipCompress -source D:\hoge\* -safe -verbose
    10
    New-ZipCompress -source D:\hoge\* -quiet -verbose
    11
    New-ZipCompress -source D:\hoge\*.ps1 -destination d:\hoge.zip -verbose
    12
    New-ZipCompress -source D:\hoge\*.ps1 -verbose
    13
    New-ZipCompress -source D:\hoge\*.ps1 -force -verbose
    14
    New-ZipCompress -source D:\hoge\*.ps1 -safe -verbose
    15
    New-ZipCompress -source D:\hoge\*.ps1 -quiet -verbose
    16
    New-ZipCompress -source R:\ -destination d:\hoge.zip -verbose
    17
    New-ZipCompress -source R:\ -verbose
    18
    New-ZipCompress -source R:\ -force -verbose
    19
    New-ZipCompress -source R:\ -safe -verbose
    20
    New-ZipCompress -source R:\ -quiet -verbose
}
catch
{
    Write-Error $_
}
```


#### Extract Test

```PowerShell
$ErrorActionPreference = "stop"

try
{
    1
    New-ZipExtract -source D:\hoge.zip -destination d:\hogehogehoge -verbose
    2
    New-ZipExtract -source D:\hoge.zip -verbose
    3
    New-ZipExtract -source D:\hoge.zip -force -verbose
    4
    New-ZipExtract -source D:\hoge.zip -safe -verbose
    5
    New-ZipExtract -source D:\hoge.zip -quiet -verbose
}
catch
{
    Write-Error $_
}
```
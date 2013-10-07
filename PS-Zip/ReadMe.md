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


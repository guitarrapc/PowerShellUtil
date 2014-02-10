# Out-File と Set-Content/Add-Content の違いについて

#region 1. 書き込み方法の違い と NoClobber による上書き防止
# 上書き保存 (ファイルがない場合は作成)
1..10 | Out-File out.log -Encoding UTF8
1..10 | Set-Content content.log -Encoding UTF8

# 上書き保存禁止 (ファイルがない場合は作成)
1..10 | Out-File outNoClobber.log -Encoding UTF8 -NoClobber
# Set-Content/Add-Content には -NoClobber がなく、上書き禁止を制限できない

# 上書き保存 (ファイルがない場合は作成/NoClobberとForceを併用するとForce(読み込み専用ファイルへの書き込み)優先)
1..10 | Out-File outNoClobberForce.log -Encoding UTF8 -NoClobber -Force
1..10 | Set-Content contentForce.log -Encoding UTF8 -Force
1..10 | Add-Content contentAddForce.log -Encoding UTF8 -Force
# Set-Content には -NoClobber がなく、上書き禁止を制御できない。つまり Forceとなる。

# 追記 (ファイルがない場合は作成)
1..10 | Out-File outAppend.log -Encoding UTF8 -Append
1..10 | Add-Content contentAdd.log -Encoding UTF8

# 追記 (ファイルがない場合は作成/NoClobberとAppendを併用するとAppend優先)
1..10 | Out-File outAppendNoClobber.log -Append -NoClobber
# Add-Content には -NoClobberがないため、上書き禁止を制御できない。
#endregion

#region 2. Write/Read Lock について
# Out-File は書き込み中は Read/Write Locking のうち Write Lockingのみ
# つまり書き込み中に、その内容を読み取れる
1..10 |%{$_;sleep -Milliseconds 500} | Out-File out.log -Encoding UTF8

# Set-Content/Add-Content は書き込み中は Read/Write Locking のうち Read/Write Locking両方がかかる
# つまり書き込み中、その内容は読み取れない
1..10 |%{$_;sleep -Milliseconds 500} | Set-Content content.log -Encoding UTF8
#endregion

#region 3. Encoding の違い
# Out-File のデフォルトエンコーディングは UCS-2 Little Endian
1..10 | Out-File outEncoding.log

# Set-Content/Add-Content のデフォルトエンコーディングは ASCII
1..10 | Set-Content contentEncoding.log

# ハッシュ値で確認するとデフォルトエンコーディングが異なることがわかる。
Get-FileHash outEncoding.log,contentEncoding.log


# Out-File も Set-Content/Add-Content もエンコーディングを指定すれば一緒
1..10 | Out-File outEncoding.log -Encoding utf8
1..10 | Set-Content contentEncoding.log -Encoding UTF8

# ハッシュ値で確認するとデフォルトエンコーディングが異なることがわかる。
Get-FileHash outEncoding.log,contentEncoding.log
#endregion

#region 4. InputObjectが空の場合のファイル作成
# Out-Fileは、結果がNullでもまずファイルを作成する
Get-ChildItem d:\empty | Out-File outNull.log         # フォルダが空でも作る

# Set-Content/Add-Contentは、結果が空だとファイルを作成しない(エラーにもならない)
Get-ChildItem d:\empty | Set-Content contentNull.log  # フォルダが空だと作らない
$null | Set-Content contentNull.log                   # これだとつくっちゃうけどね
#endregion

#region 5. PassThru の可否
# Out-File は、-PassThru スイッチを持たず、書き込み中のオブジェクトを標準出力しながら処理することができない
# Set-Content は、-PassThru スイッチにより書き込み中のオブジェクトを標準出力しながら処理可能
1..10 | Set-Content contentPassThru.log -PassThru
1..10 | Add-Content contentPassThruAdd.log -PassThru
#endregion

#region 6. Credential の可否
# Out-File は-Credential パラメータを持たず、別ユーザーとしての実施は不可　(Invoke-Command 使えばいい)
# Set-Content は、-PassThru スイッチにより書き込み中のオブジェクトを標準出力しながら処理可能
1..10 | Set-Content contentPassThru.log -Credential (Get-Credential)
#endregion

#region 7. Include/Exclude の可否
# Out-Fileは、 -Include/-Exclude スイッチがない
Get-Childitem hoge | Set-Content contentInclude -Include "*.log"
#endregion

#region 8. Filter の可否
# -Filter パラメータを持たず、対象のプロバイダに合わせたフィルタをかけることはできない。
#endregion

#region 9. Transaction の可否
# -UseTransaction スイッチがないため、Transaction処理に含めることができない
#endregion
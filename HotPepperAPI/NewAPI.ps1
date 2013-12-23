# New API
$key = "APIキーいれてね"
$foodName = "寿司"
$areaName = "新橋"
$foodCode = (Invoke-RestMethod -Method Get "http://webservice.recruit.co.jp/hotpepper/food/v1/?key=$key").results.food | where name -eq $foodName | select -ExpandProperty code
$areaCode = (Invoke-RestMethod -Method Get "http://webservice.recruit.co.jp/hotpepper/small_area/v1/?key=$key&keyword=$areaName").results.small_area | where name -eq $areaName | select -ExpandProperty code
(Invoke-RestMethod -Method Get "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=$key&food=$foodCode&small_area=$areaCode").results.shop | Format-Table -Autosize | clip


$storeName = "築地すし好　新橋三丁目店"
$urlEncodeStoreName = [System.Uri]::EscapeDataString($storeName)
$responce = Invoke-RestMethod -Method Get "http://webservice.recruit.co.jp/hotpepper/shop/v1/?key=$key&keyword=$urlEncodeStoreName"

$result = $responce.results.shop | %{
    [PSCustomObject]@{
        id = $_.id
        name = $_.name
        name_kana = $_.name_kana
        address = $_.address
        genre = $_.genre.name
        urls_pc = $_.urls.pc
        urls_mobile = $_.urls.mobile
        urls_qr = $_.urls.qr
        desc = $_.desc
    }}
$result
if ($result.count -ne 0)
{
    # IE, Chrome, Opera
    $browsers = @("C:\Program Files\Internet Explorer\iexplore.exe",
                 "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                 "C:\Program Files\Opera\opera.exe")
    $browser = $browsers.where({Test-Path $_},"last",1)
    & $browser $result.urls_pc
}
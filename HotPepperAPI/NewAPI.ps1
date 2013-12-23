# New API
$key = "APIキーいれてね"
$storeName = "築地すし好　新橋三丁目店"
$areaName = "新橋"
$foodCode = (Invoke-RestMethod -Method Get "http://webservice.recruit.co.jp/hotpepper/food/v1/?key=$key").results.food | where name -eq "寿司" | select -ExpandProperty code
$areaCode = (Invoke-RestMethod -Method Get "http://webservice.recruit.co.jp/hotpepper/small_area/v1/?key=$key&keyword=新橋").results.small_area | where name -eq "新橋" | select -ExpandProperty code
(Invoke-RestMethod -Method Get "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=$key&food=$foodCode&small_area=$areaCode").results.shop | Format-Table -Autosize | clip


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
                 "C:\Program Files (x86)\Google\Opera\opera.exe")
    $browser = $browsers.where({Test-Path $_},"last",1)
    & $browser $result.urls_pc
}
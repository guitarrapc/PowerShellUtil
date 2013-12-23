# Old API
$key = "APIキーいれてね"
$storeName = "築地すし好　新橋三丁目店"
$urlEncodeStoreName = [System.Uri]::EscapeDataString($storeName)
$responce = Invoke-RestMethod -Method Get "http://api.hotpepper.jp/GourmetSearch/V110/?key=$key&ShopName=$urlEncodeStoreName"
$result = $responce.Results.Shop
$result
if ($result.count -ne 0)
{
    # IE, Chrome, Opera
    $browsers = @("C:\Program Files\Internet Explorer\iexplore.exe",
                 "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                 "C:\Program Files (x86)\Google\Opera\opera.exe")
    $browser = $browsers.where({Test-Path $_},"last",1)
    & $browser $result.ShopUrl
}
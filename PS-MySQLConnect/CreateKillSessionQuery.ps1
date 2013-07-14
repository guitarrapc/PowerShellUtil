
$ImportCSV = "processlist.txt"

$csv = Import-Csv -Path .\$ImportCSV

$ExcludeIP = "10.0.0.100"
$KillQueryType = "select*"
$ExcludeUser = "adminUser"

$sql = $csv | where User -ne $ExcludeUser | where Host -ne $ExcludeIP | where Info -like $KillQueryType | %{"kill " + $_.id + ";"}
$sql | clip

<# Import csv format sample
Id,User,Host,db,Command,Time,State,Info
205722733,hogeUser,10.0.0.149:38189,hogetable,Query,1813,Sending data,SELECT `id` FROM `hogetable` AS `hoge` WHERE `login` = '2013-07-03 23:59:59',15
205722799,adminUser,10.0.0.227:38591,hogetable,Query,1814,Sending data,SELECT `id` FROM `hogetable` AS `hoge` WHERE `login` = '2013-07-03 23:59:59',15
#>
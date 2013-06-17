Benchmark to get PC_Name and IpAddress

    ### PCNAME�̎擾
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$([Net.Dns]::GetHostName())`t<<`t$(&$using:Command)"} #121.98ms
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$($Env:COMPUTERNAME)`t<<`t$(&$using:Command)"} #147.0818ms
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$(hostname)`t<<`t$(&$using:Command)"} #165.8101ms
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$((Get-CimInstance -Class Win32_ComputerSystem).Name)`t<<`t$(&$using:Command)"} #389.68ms

    ### IPADDRESS�̎擾
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$([Net.Dns]::GetHostAddresses('').IPAddressToString[1])`t<<`t $(&$($using:Command))"} #189.55ms
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$([Net.Dns]::GetHostAddresses('').IPAddressToString)`t<<`t$(&$using:Command)"} #289.31ms
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$(ipconfig | where{$_ -match "IPv4 Address. . . . . . . . . . . : (?<ip>.*)"} | %{$Matches.ip})`t<<`t$(&$using:Command)"} #386.26ms
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$((Get-NetIPAddress | where{$_.InterfaceAlias -eq "Ethernet"}).IPAddress)`t<<`t$(&$using:Command)"} #1183.11ms
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$(Get-NetIPAddress | where InterfaceAlias -eq "Ethernet" | select -ExpandProperty IPAddress)`t<<`t$(&$using:Command)"} #1200.11ms
    #$ScriptBlock = {"$((Get-Date).ToString("yyyyMMdd hh:mm:ss"))`t$(Get-NetIPAddress | where{$_.InterfaceAlias -eq "Ethernet"} | select -ExpandProperty IPAddress)`t<<`t$(&$using:Command)"} #1233.11ms

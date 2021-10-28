$port = 8080
(Get-NetTCPConnection -LocalPort $port -State Listen).OwningProcess | %{Get-Process -Id $_}

# RESULT
# Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
# -------  ------    -----      -----     ------     --  -- -----------
#     202      29     1580       5432       0.02  18228   1 wslhost
#     307      38    22840      22220       3.58  17372   1 com.docker.backend
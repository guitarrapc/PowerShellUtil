Install-Module -Name UnitySetup -AllowPrerelease -Scope CurrentUser -Force
Find-UnitySetupInstaller -Version '2019.1.5f1' -Components "Mac", "Android", "iOS" | Install-UnitySetupInstance
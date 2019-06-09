Install-Module -Name UnitySetup -AllowPrerelease -Scope CurrentUser -Force
Find-UnitySetupInstaller -Version '2018.3.13f1' -Components "Windows", "UWP_IL2CPP", "Vuforia" | Install-UnitySetupInstance
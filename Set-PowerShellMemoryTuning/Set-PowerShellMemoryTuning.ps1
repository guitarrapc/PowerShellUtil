function Set-PowerShellMemoryTuning{

    param(
        [parameter(
            position = 0,
            mandatory = 1)]
        [ValidateNotNullorEmpty()]
        [ValidateRange(1,2147483647)]
        [int]
        $memory
    )

    # Test Elevated or not
    $TestElevated = {
        $user = [Security.Principal.WindowsIdentity]::GetCurrent()
        (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    }

    if (&$TestElevated)
    {

        # Machine Wide Memory Tuning
        Write-Warning "Current Memory for Machine wide is : $((Get-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB).value) MB"

        Write-Warning "Change Memory for Machine wide to : $memory MB"
        Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB $memory


        # EndPoing Memory Tuning
        Write-Warning "Current Memory for Plugin is : $((Get-Item WSMan:localhost\Plugin\microsoft.powershell\Quotas\MaxConcurrentCommandsPerShell).value) MB"

        Write-Warning "Change Memory for Plugin to : $memory MB"
        Set-Item WSMan:localhost\Plugin\microsoft.powershell\Quotas\MaxConcurrentCommandsPerShell $memory


        # Restart WinRM
        Write-Warning "Restarting WinRM"
        Restart-Service WinRM -Force -PassThru


        # Show Current parameters
        Write-Warning "Current Memory for Machine wide is : $((Get-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB).value) MB"
        Write-Warning "Current Memory for Plugin is : $((Get-Item WSMan:localhost\Plugin\microsoft.powershell\Quotas\MaxConcurrentCommandsPerShell).value) MB"
    }
    else
    {
        Write-Error "This Cmdlet requires Admin right. Please Elevate and try again."
    }

}
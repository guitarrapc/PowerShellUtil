function Add-DefenderExclusionForDevEnv {
    Set-StrictMode -Version Latest

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $me = $MyInvocation.MyCommand
        $myDefinition = (Get-Command $me).Definition
        $myfunction = "function $me { $myDefinition }"

        $cd = (Get-Location).Path
        $commands = "Set-Location $cd; $myfunction; Write-Host 'Running $me'; $me; Pause"
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($commands)
        $encode = [Convert]::ToBase64String($bytes)
        $argumentList = "-NoProfile","-EncodedCommand", $encode

        Write-Warning "Detected you are not runnning with Admin Priviledge."
        $proceed = Read-Host "Required elevated priviledge to add exlusion to Windows Defender. Do you proceed? (y/n)"
        if ($proceed -ceq "y") {
            $p = Start-Process -Verb RunAs powershell.exe -ArgumentList $argumentList -Wait -PassThru
            return $p.ExitCode
        }
        else {
            Write-Host "Cancel evelated."
            return 1
        }
    }

    Write-Host "Welcome to AddDefenderExclusionForDevEnv"
    Write-Host "Create Windows Defender exclusions for common Visual Studio folders and processes to fasten your Build."

    $pathExclusions = (Get-ChildItem ${env:ProgramFiles(x86)} -Filter "Microsoft Visual Studio*" -Directory).FullName
    $pathExclusions += (
        "${env:WinDir}\Microsoft.NET",
        "${env:WinDir}\assembly",
        "${env:LOCALAPPDATA}\Microsoft\VisualStudio",
        "${env:ProgramData}\Microsoft\VisualStudio\Packages",
        "${env:ProgramFiles(x86)}\MSBuild",
        "${env:ProgramFiles(x86)}\Microsoft SDKs\NuGetPackages",
        "${env:ProgramFiles(x86)}\Microsoft SDKs"
    )
    $processExclusions = @(
        'devenv.exe',
        'dotnet.exe',
        'msbuild.exe',
        'node.exe',
        'node.js',
        'perfwatson2.exe',
        'ServiceHub.Host.Node.x86.exe',
        'vbcscompiler.exe'
    )

    $projectsFolder = Read-Host 'Input path to your Project folder. (eg.,: c:\projects)'

    if (![string]::IsNullOrWhiteSpace($projectsFolder)){
        Write-Host "Adding Path Exclusion: " $projectsFolder
        Add-MpPreference -ExclusionPath $projectsFolder
    }
    else {
        Write-Host "Path was blank, skip adding."
    }

    foreach ($exclusion in $pathExclusions) {
        Write-Host "Adding Path Exclusion: " $exclusion
        Add-MpPreference -ExclusionPath $exclusion
    }

    foreach ($exclusion in $processExclusions) {
        Write-Host "Adding Process Exclusion: " $exclusion
        Add-MpPreference -ExclusionProcess $exclusion
    }

    Write-Host "Your Exclusions:"
    $prefs = Get-MpPreference
    $prefs.ExclusionPath
    $prefs.ExclusionProcess

    Write-Host "Enjoy faster build time."
}
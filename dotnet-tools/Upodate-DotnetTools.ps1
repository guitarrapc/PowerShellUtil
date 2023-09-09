<#
.SYNOPSIS
    Update all dotnet tools installed on the system.
    See https://learn.microsoft.com/en-us/dotnet/core/tools/global-tools for dotnet-tools.
.EXAMPLE
    # Update Project's dotnet tools
    Update-DotnetTools
    # Update Global dotnet tools
    Update-DotnetTools -Global
#>
function Update-DotnetTools {
    param(
        [Switch]$Global
    )

    $globalSwitch = ""
    if ($Global) {
        $globalSwitch = "-g"
    }

    # $ dotnet tool list -g
    # Package Id            Version      Commands
    # ---------------------------------------------------
    # dotnet-ildasm         0.12.2       dotnet-ildasm
    # unitybuildrunner      3.4.0        UnityBuildRunner
    $tools = dotnet tool list $globalSwitch | Select-Object -Skip 2
    # dotnet-ildasm         0.12.2       dotnet-ildasm
    # unitybuildrunner      3.4.0        UnityBuildRunner

    foreach ($tool in $tools) {
        # dotnet-ildasm         0.12.2       dotnet-ildasm
        # 13
        $end = $tool.IndexOf(" ")
        # dotnet-ildasm
        $toolName = ($tool.Substring(0, $end)).Trim()
        dotnet tool update $globalSwitch "$toolName"
    }
}

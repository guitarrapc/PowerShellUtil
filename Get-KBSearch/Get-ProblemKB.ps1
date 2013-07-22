param(
    [string]
    $kb="KB2823324"
)


Get-WmiObject -Class Win32_QuickFixEngineering `
    | %{ 
        if($_.HotFixID -eq $kb)
        {
            "$kb found. Opening application list, let's uninstall $kb."
            Invoke-Command {appwiz.cpl}
        }
        else
        {
            "$kb not found. Lucky you!"
        }
    } `
    | sort -Unique `
    | select -First 1

pause


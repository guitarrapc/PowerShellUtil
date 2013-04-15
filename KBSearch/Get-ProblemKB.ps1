param(
    [string]
    $kb="KB2823324"
)

Get-WmiObject -Class Win32_QuickFixEngineering `
    | %{ 
        if($_.HotFixID -eq $kb)
        {
            "$kb found. let's uninstall it."
            Invoke-Command {appwiz.cpl}
        }
        else
        {
            
        }
    }
pause
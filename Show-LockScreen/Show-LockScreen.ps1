Function Show-LockScreen{

    [CmdletBinding()]
    param(
        [int]
        $Sleep,

        [string]
        $Context="このロックスクリーンはPowerShellで描かれています！ $sleep　秒待ってね♡",

        [string]
        $LabelColour = 'Indigo',

        [string]
        $BackgroundColour = "#88AA55",

        [double]
        [ValidateScript({($_ -le 1.0) -and ($_ -gt 0)})]
        $Opacity = 0.4
    )

    begin
    {
        try
        {
            $label = New-Object Windows.Controls.Label
        }
        catch
        {
        }
        $label.Content = $Context
        $label.FontSize = 60
        $label.FontFamily = 'Consolas'
        $label.Background = 'Transparent'
        $label.Foreground = $LabelColour
        $label.HorizontalAlignment = 'Center'
        $label.VerticalAlignment = 'Center'

        try
        {
            $window = New-Object Windows.Window
        }
        catch
        {
        }
        $Window.AllowsTransparency = $True
        $Window.Opacity = $Opacity
        $window.WindowStyle = 'None'
        $window.Background = $BackgroundColour
        $window.Content = $label
        $window.Left = $window.Top = 0
        $window.WindowState = 'Maximized'
        $window.Topmost = $true
    }
    
    process
    {
        $window.Show() > $null
        Start-Sleep -Seconds $Sleep
        $window.Close()
    }
    end
    {
    }
}


Show-LockScreen -Sleep 5 -Opacity 0.5 -LabelColour "Indigo" -BackgroundColour "SkyBlue"
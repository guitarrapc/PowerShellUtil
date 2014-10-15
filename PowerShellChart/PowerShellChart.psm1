#Requires -Version 3.0

# Original is here
# http://goodworkaround.com/node/64

# This sample modify original as below
# 1. Remove all Exit
# 2. Change to show ToolChip
# 3. Change to select show Label
# 4. Change into Module
#
# Modified by guitarrapc
# 11.Oct.2014

# .Example
<#
$osloTemperature = [ordered]@{}
[xml]$weather = (Invoke-WebRequest -Uri http://www.yr.no/place/Norway/Oslo/Oslo/Oslo/varsel.xml).Content
$weather.weatherdata.forecast.tabular.time | foreach { $osloTemperature[$_.from] = $_.temperature.value }
 
# Create chart, add dataset and show
New-Chart -Title "Temperature in Oslo" -XInterval 4 -YInterval 2 -Width 1200 `
| Add-Chart -Dataset $osloTemperature -DatasetName "Temperature" -SeriesChartType Spline -OutVariable tempChart `
| Show-Chart
#>

try
{
    # Load assembly for Microsoft Chart Controls for Microsoft .NET Framework 3.5
    Write-Verbose "Loading assemblies"
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization
}
catch
{
}

<#
.Synopsis
   Creates a new chart
.DESCRIPTION
   New-Chart creates a new chart object with an optional default dataset. This object is a System.Windows.Forms.DataVisualization.Charting.ChartArea and can be used with either the other methods in this module, or manually.
.EXAMPLE
   New-Chart -Dataset @{"Oslo"=12;"Bergen"=14;"Trondheim"=11}
 
   Returns a simple chart with a default dataset
.EXAMPLE
   New-Chart -Xinterval 2 -Width 800
 
   Returns a simple empty chart with xinterval and width set
#>
function New-Chart
{
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.DataVisualization.Charting.ChartArea])]
    Param
    (
        # Dataset
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$false, Position=0)]
        $Dataset,
 
        # Width
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [int]$Width = 500,
 
        # Height
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [int]$Height = 500,
 
        # X Interval
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [int]$XInterval,
 
        # Y Interval
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [int]$YInterval,
 
        # X Title
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [string]$XTitle,
 
        # Y Title
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [string]$YTitle,
 
        # Title
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [string]$Title
    )


    process
    {
        # Create chart
        Write-Verbose "Creating chart $Width x $Height"
        $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
        $Chart.Width = $Width
        $Chart.Height = $Height
        $Chart.Left = 0
        $Chart.Top = 0
 
        # Add chart area to chart
        $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $Chart.ChartAreas.Add($ChartArea)
 
        # Set titles and lables
        if($Title)
        {
            Write-Verbose "Setting title: $Title"
            [void]$Chart.Titles.Add($Title)
        }
        else
        {
            Write-Verbose "No title provided"
        }
 
        if($YTitle)
        {
            Write-Verbose "Setting Ytitle: $YTitle"
            $ChartArea.AxisY.Title = $YTitle
        }
        else
        {
            Write-Verbose "No Ytitle provided"
        }
 
        if($XTitle)
        {
            Write-Verbose "Setting Xtitle: $XTitle"
            $ChartArea.AxisX.Title = $XTitle
        }
        else
        {
            Write-Verbose "No Xtitle provided"
        }
 
        if($YInterval)
        {
            Write-Verbose "Setting Y Interval to $YInterval"
            $ChartArea.AxisY.Interval = $YInterval
        }
 
        if($XInterval)
        {
            Write-Verbose "Setting X Interval to $XInterval"
            $ChartArea.AxisX.Interval = $XInterval
        }
   
        if($Dataset)
        {
            Write-Verbose "Dataset provided. Adding this as ""default dataset"" with chart type line."
            [void]$Chart.Series.Add("default dataset")
            $Chart.Series["default dataset"].Points.DataBindXY($Dataset.Keys, $Dataset.Values)
            $Chart.Series["default dataset"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
        }
   
        return $Chart
    }
}
 
 
 
<#
.Synopsis
   Adds a dataset to a chart
.DESCRIPTION
   Accepts a System.Windows.Forms.DataVisualization.Charting.ChartArea as input, adds a dataset and returns the same chart
.EXAMPLE
   New-Chart | Add-ChartDataset -Dataset @{"Oslo"=12;"Bergen"=14;"Trondheim"=11} -Datasetname "Cities in Norway"
.EXAMPLE
   New-Chart | Add-ChartDataset -Dataset $dataset -SeriesChartType Spline
#>
function Add-ChartDataset
{
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.DataVisualization.Charting.ChartArea])]
    Param
    (
        # Chart
        [Parameter(Mandatory=$true,ValueFromPipeline=$true, Position=0)]
        [System.Windows.Forms.DataVisualization.Charting.Chart]$Chart,
 
        # Dataset
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$false, Position=0)]
        $Dataset,
 
        # DatasetName
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$false, Position=1)]
        [string]$DatasetName = "Added dataset",
 
        # SeriesChartType = http://msdn.microsoft.com/en-us/library/system.windows.forms.datavisualization.charting.seriescharttype(v=vs.110).aspx
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$false, Position=2)]
        [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]$SeriesChartType = "Line",
        
        [bool]$ShowLabel = $false
    )
 
    process
    {
        Write-Verbose "Create series with ChartType"
        $series = New-Object System.Windows.Forms.DataVisualization.Charting.Series 
        $series.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::$SeriesChartType

        Write-Verbose "Adding data binding"
        foreach ($item in $Dataset.GetEnumerator())
        {
            $x = $item.Key.ToString()
            $y = $item.Value.ToString()
            $index = $Series.Points.AddXY($x, $y)
            $series.Points[$index].ToolTip = "{0}, {1}" -f $x, $y
            if ($ShowLabel){ $series.Points[$index].Label = $y }
        }

        Write-Verbose "Adding series $Datasetname"
        [void]$Chart.Series.Add($series)

        return $Chart
    }
}
 
<#
.Synopsis
   Shows chart on screen
.DESCRIPTION
   Create a windows form and displays a chart in it
.EXAMPLE
   New-Chart -Dataset @{"Oslo"=12;"Bergen"=14;"Trondheim"=11} | Show-Chart
#>
function Show-Chart
{
    [CmdletBinding()]
    [OutputType([void])]
    Param
    (
        # Chart
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [System.Windows.Forms.DataVisualization.Charting.Chart]$Chart
    )

    end
    {
        # display the chart on a form
        $Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
        $Form = New-Object Windows.Forms.Form
        $Form.Text = "PowerShell Chart"
        $Form.Width = $chart.Width
        $Form.Height = $chart.Height + 50
        $Form.controls.add($Chart)
        $Form.Add_Shown({$Form.Activate()})
        $Form.ShowDialog() > $null
    }
}

#-- Export Modules when loading this module --#

Export-ModuleMember `
    -Function *-Chart `
    -Cmdlet * `
    -Variable *
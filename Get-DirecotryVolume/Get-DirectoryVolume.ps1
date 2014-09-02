function Get-DirectoryVolume
{

    [CmdletBinding()]
    param
    (
        [parameter(
            position = 0,
            mandatory = 1,
            valuefrompipeline = 1,
            valuefrompipelinebypropertyname = 1)]
        [string[]]
        $Path = $null,

        [parameter(
            position = 1,
            mandatory = 0,
            valuefrompipelinebypropertyname = 1)]
        [validateSet("KB", "MB", "GB")]
        [string]
        $Scale = "KB",

        [parameter(
            position = 2,
            mandatory = 0,
            valuefrompipelinebypropertyname = 1)]
        [switch]
        $Recurse = $false,

        [parameter(
            position = 3,
            mandatory = 0,
            valuefrompipelinebypropertyname = 1)]
        [switch]
        $Ascending = $false,

        [parameter(
            position = 4,
            mandatory = 0,
            valuefrompipelinebypropertyname = 1)]
        [switch]
        $OmitZero
    )

    process
    {
        $path `
        | %{
            Write-Verbose ("Checking path : {0}. Scale : {1}. Recurse switch : {2}. Decending : {3}" -f $_, $Scale, $Recurse, !$Ascending)
            if (Test-Path $_)
            {
                $result = Get-ChildItem -Path $_ -Recurse:$Recurse `
                | where PSIsContainer `
                | %{
                    $subFolderItems = (Get-ChildItem $_.FullName | where Length | measure Length -sum)
                    [PSCustomObject]@{
                        Fullname = $_.FullName
                        $scale = [decimal]("{0:N4}" -f ($subFolderItems.sum / "1{0}" -f $scale))
                    }} `
                | sort $scale -Descending:(!$Ascending)

                if ($OmitZero)
                {
                    return $result | where $Scale -ne ([decimal]("{0:N4}" -f "0.0000"))
                }
                else
                {
                    return $result
                }
            }
        }
    }
}

Get-DirectoryVolume -path D:\GitHub, c:\logs -scale KB
Get-DirectoryVolume -path D:\GitHub, c:\logs -scale KB -Ascending
Get-DirectoryVolume -path D:\GitHub, c:\logs -scale KB -Ascending -OmitZero
"c:\logs", "D:\GitHub" | Get-DirectoryVolume  -scale KB
"c:\logs", "D:\GitHub" | Get-DirectoryVolume  -scale MB -Recurse -Verbose


<#
# Oneliner
Get-ChildItem c:\logs -Recurse | where PSIsContainer | %{$i=$_;$subFolderItems = (Get-ChildItem $i.FullName | where Length | measure Length -sum);[PSCustomObject]@{Fullname=$i.FullName;MB=[decimal]("{0:N2}" -f ($subFolderItems.sum / 1MB))}} | sort MB -Descending | ft -AutoSize

# refine oneliner
Get-ChildItem c:\logs -Recurse `
| where PSIsContainer `
| %{
    $i=$_
    $subFolderItems = (Get-ChildItem $i.FullName | where Length | measure Length -sum)
    [PSCustomObject]@{
        Fullname=$i.FullName
        MB=[decimal]("{0:N2}" -f ($subFolderItems.sum / 1MB))
    }} `
| sort MB -Descending `
| format -AutoSize


# if devide each
$folder = Get-ChildItem c:\logs -recurse | where PSIsContainer
[array]$volume = foreach ($i in $folder)
{
    $subFolderItems = (Get-ChildItem $i.FullName | where Length | measure Length -sum)
    [PSCustomObject]@{
        Fullname=$i.FullName
        MB=[decimal]("{0:N2}" -f ($subFolderItems.sum / 1MB))
    }
}
$volume | sort MB -Descending | ft -AutoSize
18:53

#>
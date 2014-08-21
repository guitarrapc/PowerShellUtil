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
        [string]
        $path = $null,

        [parameter(
            position = 1,
            mandatory = 0,
            valuefrompipelinebypropertyname = 1)]
        [string]
        $scale = "1KB"
    )

    Get-ChildItem -Path $path -Recurse `
    | where PSIsContainer `
    | %{
        $subFolderItems = (Get-ChildItem $_.FullName | where Length | measure Length -sum)
        [PSCustomObject]@{
            Fullname = $_.FullName
            MB = [decimal]("{0:N2}" -f ($subFolderItems.sum / $scale))
        }} `
    | sort $scale -Descending
}

Get-DirectoryVolume -path C:\Logs


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
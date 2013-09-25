function Get-DirectoryVolume{

    [CmdletBinding()]
    param(
        [parameter(
            position = 0,
            mandatory,
            valuefrompipelinebypropertyname,
            valuefrompipeline)]
        [string]
        $path = $null,

        [parameter(
            position = 1,
            mandatory = 0,
            valuefrompipelinebypropertyname,
            valuefrompipeline)]
        [string]
        $scale = "MB"
    )

    Get-ChildItem $path -Recurse `
        | where PSIsContainer `
        | %{
            $i = $_
            $subFolderItems = (Get-ChildItem $i.FullName | where Length | measure Length -sum)
            [PSCustomObject]@{
                Fullname = $i.FullName
                MB = [decimal]("{0:N2}" -f ($subFolderItems.sum / 1MB))
            }} `
        | sort $scale -Descending `
        | Format-Table -AutoSize
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
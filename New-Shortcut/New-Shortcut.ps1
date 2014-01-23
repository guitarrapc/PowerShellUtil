function New-Shortcut
{
<#
.Synopsis
   Create file shortcut.
.DESCRIPTION
   You can create file shortcut into desired directory.
   Both Pipeline input and parameter input is supported.
.EXAMPLE
   New-Shortcut -TargetPaths "C:\Users\Administrator\Documents\hogehoge.csv" -Verbose -PassThru
    # Set Target full path in -TargetPaths (you can set multiple path). 
    # Set Directory to create shortcut in -ShortcutDirectory (Default is user Desktop).
    # Set -Verbose to sett Verbose status
    # Set -PassThru to output Shortcut creation result.

.NOTES
   Make sure file path is valid.
.COMPONENT
   COM
#>
    [CmdletBinding()]
    [OutputType([System.__ComObject])]
    param
    (
        # Set Target full path to create shortcut
        [parameter(
            position  = 0,
            mandatory = 1,
            ValueFromPipeline = 1,
            ValueFromPipeLineByPropertyName = 1)]
        [validateScript({$_ | %{Test-Path $_}})]
        [string[]]
        $TargetPaths,

        # set shortcut Directory to create shortcut. Default is user Desktop.
        [parameter(
            position  = 1,
            mandatory = 0,
            ValueFromPipeLineByPropertyName = 1)]
        [validateScript({-not(Test-Path $_)})]
        [string]
        $ShortcutDirectory = "$env:USERPROFILE\Desktop",

        # Set Description for shortcut.
        [parameter(
            position  = 2,
            mandatory = 0,
            ValueFromPipeLineByPropertyName = 1)]
        [string]
        $Description,

        # set if you want to show create shortcut result
        [parameter(
            position  = 3,
            mandatory = 0)]
        [switch]
        $PassThru
    )

    begin
    {
        $extension = ".lnk"
        $wsh = New-Object -ComObject Wscript.Shell
    }

    process
    {
        foreach ($TargetPath in $TargetPaths)
        {
            Write-Verbose ("Get filename from original target path '{0}'" -f $TargetPath)
            # Create File Name from original TargetPath
            $fileName = Split-Path $TargetPath -Leaf
            
            # set Path for Shortcut
            $path = Join-Path $ShortcutDirectory ($fileName + $extension)

            # Call Wscript to create Shortcut
            Write-Verbose ("Trying to create Shortcut for name '{0}'" -f $path)
            $shortCut = $wsh.CreateShortCut($path)
            $shortCut.TargetPath = $TargetPath
            $shortCut.Description = $Description
            $shortCut.Save()

            if ($PSBoundParameters.PassThru)
            {
                Write-Verbose ("Show Result for shortcut result for target file name '{0}'" -f $TargetPath)
                $shortCut
            }
        }
    }

    end
    {
    }
}
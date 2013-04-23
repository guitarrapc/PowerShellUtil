#Requires -Version 2.0

# --------------------------------
# << DESCRIPTION >>
#
#  - git pull utilities for images
# 
# << SUMMARY >>
#
#  - Sync image files with git with following commands
#
#   1. git add -A
#      : will upload any changed file in local
#
#   2. git commit -a -m "hogemoge"
#      : will commit change in local with remote repositoty and message for "hogemoge"       
#
#   3. git pull
#      : pull latest file from remote repository
#
# --------------------------------

function Start-Git{

    [CmdletBinding(  
        SupportsShouldProcess = $false,
        ConfirmImpact = "none",
        DefaultParameterSetName = ""
    )]
    param
    (
        [Parameter(
        HelpMessage = "Input Full path of Git",
        Position = 0,
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_.FullName})]
        [IO.FileInfo[]]
        $GitPath,
 
        [Parameter(
        HelpMessage = "Input path of Log",
        Position = 1,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_.FullName})]
        [IO.FileInfo[]]
        $LogPath,

        [Parameter(
        HelpMessage = "Input name of Log",
        Position = 2,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogName,

        [Parameter(
        HelpMessage = "Git Commit Comment",
        Position = 3,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $GitCommitComment
    )

    Begin
    {
        # Set current directory to git direcotry (same as cd)
        Set-Location $GitPath

        # Check for git directory
        if (!(Test-Path $logDir))
        {
            New-Item -ItemType Directory -Path $logDir
        }

        # configure log file and fullpath
        $date = (Get-Date).ToString("yyyyMMdd")
        $logName = "git_$date.log"
        $logFullPath = Join-Path $logDir $logName

    }

    process
    {
        git add -A >> $logFullPath 2>&1
        git commit -a -m $GitCommitComment >> $logFullPath 2>&1
        git pull >> $logFullPath 2>&1
    }
}



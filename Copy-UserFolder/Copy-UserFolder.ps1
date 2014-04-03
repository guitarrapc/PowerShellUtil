function Main
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]
        $SourceUserName,

        [parameter(Mandatory)]
        [string]
        $TargetUserName
    )

    Show-Caution

    $SourceUserName, $TargetUserName `
    | %{
        Write-Host ("Starting backup SourceUserName '{0}'" -f $_) -ForegroundColor Cyan
        Backup-UserDirectory -userName $_
    }

    Write-Host ("Starting Copy SourceUser '{0}' to TargetUser '{1}'" -f $SourceUserNamem, $TargetUserName) -ForegroundColor Cyan
    Copy-TargetDirectory -SourceUserName $SourceUserName -DestinationUserName $TargetUserName
}


function Get-UserFolders
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 0,
            position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $usersPath = (Split-Path $env:USERPROFILE -Parent)
    )

    Get-ChildItem -Path $usersPath
}

function Get-BackupDirectory
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 0,
            position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $userPath = $env:USERPROFILE,

        [parameter(
            mandatory = 0,
            position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $backupName = ('backup_{0}' -f (Get-Date).ToString('yyyyMMdd_HHmmss'))
    )

    $backupDir = Join-Path $userPath 'Backup'
    return  Join-Path $backupDir $backupName
}

function Test-BackupDirectory
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 0,
            position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $backupPath = (Get-BackupDirectory)
    )

    Test-Path $backupPath
}

function New-BackupDirectory
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 0,
            position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $backupPath = (Get-BackupDirectory)
    )

    New-Item -Path $backupPath -ItemType Directory -Force

}

function Backup-UserDirectory
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 0,
            position  = 0)]
        [ValidateNotNullOrEmpty()]
        [validateScript({$_ -in (Get-UserFolders).Name})]
        [string]
        $userName
    )

    begin
    {
        $userPath = (Get-UserFolders | where Name -eq $userName).FullName        
        $backupPath = Get-BackupDirectory -userPath $userPath

        if (-not (Test-BackupDirectory -backupPath $backupPath))
        {
            New-BackupDirectory -backupPath $backupPath
        }
    }

    process
    {
        Get-ChildItem -Path $userPath `
        | where Name -notin "backup", "SharePoint","SkyDrive","DropBox", "SkyDrive Pro" `
        | %{Copy-Item -Path $_.FullName -Destination $backupPath -Recurse -ErrorAction SilentlyContinue}
    }
}


function Copy-TargetDirectory
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 1,
            position  = 0)]
        [ValidateNotNullOrEmpty()]
        [validateScript({$_ -in (Get-UserFolders).Name})]
        [string]
        $SourceUserName,

        [parameter(
            mandatory = 1,
            position  = 1)]
        [ValidateNotNullOrEmpty()]
        [validateScript({$_ -in (Get-UserFolders).Name})]
        [string]
        $DestinationUserName
    )

    begin
    {
        $SourceUserPath = (Get-UserFolders | where Name -eq $SourceUserName).FullName
        $DestinationUserPath = (Get-UserFolders | where Name -eq $DestinationUserName).FullName

        if ($null -eq $SourceUserPath)
        {
            Throw "'{0}' not found exception!" -f $SourceUserPath
        }

        if ($null -eq $DestinationUserName)
        {
            Throw "'{0}' not found exception!" -f $DestinationUserName
        }
    }

    process
    {
        Get-ChildItem -Path $SourceUserPath `
        | where Name -notin "backup", "SharePoint","SkyDrive","DropBox", "SkyDrive Pro" `
        | %{
            $item = $_
            switch ($item.PSIsContainer)
            {
                $true  {
                    Write-Verbose "Target is 'Directory'"
                    $param = @{
                    Path        = $item.FullName
                    Destination = $item.FullName.Replace($item.BaseName,"").Replace($SourceUserPath,$DestinationUserPath)}
                    Copy-Item @param -Force -ErrorAction SilentlyContinue -Recurse
                }
                $false {
                    Write-Verbose "Target is 'File'"
                    $param = @{
                    Path        = $item.FullName
                    Destination = $item.FullName.Replace($SourceUserPath,$DestinationUserPath)}
                    Copy-Item @param -Force -ErrorAction SilentlyContinue -Recurse
                }
            }
        }
    }
}


function Show-ValentiaPromptForChoice
{

    [CmdletBinding()]
    param
    (
        # input prompt items with array. second index is for help message.
        [parameter(
            mandatory = 0,
            position = 0)]
        [string[]]
        $questions = $valentia.promptForChoice.questions,

        # input title message showing when prompt.
        [parameter(
            mandatory = 0,
            position = 1)]
        [string[]]
        $title = $valentia.promptForChoice.title,
                
        # input message showing when prompt.
        [parameter(
            mandatory = 0,
            position = 2)]
        [string]
        $message = $valentia.promptForChoice.message,

        # input additional message showing under message.
        [parameter(
            mandatory = 0,
            position = 3)]
        [string]
        $additionalMessage = $valentia.promptForChoice.additionalMessage,
        
        # input Index default selected when prompt.
        [parameter(
            mandatory = 0,
            position = 4)]
        [int]
        $defaultIndex = $valentia.promptForChoice.defaultIndex
    )

    $ErrorActionPreference = $valentia.errorPreference
    
    try
    {
        # create caption Messages
        if(-not [string]::IsNullOrEmpty($additionalMessage))
        {
            $message += ([System.Environment]::NewLine + $additionalMessage)
        }

        # create dictionary include dictionary <int, KV<string, string>> : accessing KV <string, string> with int key return from prompt
        $script:dictionary = New-Object 'System.Collections.Generic.Dictionary[int, System.Collections.Generic.KeyValuePair[string, string]]'
        
        foreach ($question in $questions)
        {
            if ($private:count -eq 1)
            {
                # create key to access value
                $private:key = "n"
            }
            else
            {
                # create key to access value
                $private:key = "y"
            }

            # create KeyValuePair<string, string> for prompt item : accessing value with 1 letter Alphabet by converting char
            $script:keyValuePair = New-Object 'System.Collections.Generic.KeyValuePair[string, string]'($key, $question)
            
            # add to Dictionary
            $dictionary.Add($count, $keyValuePair)

            # increment to next char
            $count++

            # prompt limit to max 26 items as using single Alphabet charactors.
            if ($count -gt 26)
            {
                throw ("Not allowed to pass more then '{0}' items for prompt" -f ($dictionary.Keys).count)
            }
        }

        # create choices Collection
        $script:collectionType = [System.Management.Automation.Host.ChoiceDescription]
        $script:choices = New-Object "System.Collections.ObjectModel.Collection[$CollectionType]"

        # create choice description from dictionary<int, KV<string, string>>
        foreach ($dict in $dictionary.GetEnumerator())
        {
            foreach ($kv in $dict)
            {
                # create prompt choice item. Currently you could not use help message.
                $private:choice = (("{0} (&{1}){2}-" -f $kv.Value.Value, "$($kv.Value.Key)".ToUpper(), [Environment]::NewLine), ($valentia.promptForChoice.helpMessage -f $kv.Value.Key, $kv.Value.Value))

                # add to choices
                $choices.Add((New-Object $CollectionType $choice))
            }
        }

        # show choices on host
        $script:answer = $host.UI.PromptForChoice($title, $message, $choices, $defaultIndex)

        # return value from key
        return ($dictionary.GetEnumerator() | where {$_.Key -eq $answer} | %{$_.Value.Value})
    }
    catch
    {
        throw $_
    }
}


function Show-Caution
{
    $answer = Show-ValentiaPromptForChoice -questions ("はい","いいえ") -title "ユーザーフォルダをコピーします。影響しそうなプログラムは閉じておきましょう。。" -message "未保存のファイルはすべて保存しましたか？実行しますよ。"

    if ($answer -eq "はい")
    {
        return
    }
    else
    {
        Write-Host "処理は実施前にキャンセルされました。"
        if ($PSVersionTable.PSVersion -gt "2.0")
        {
            pause
        }
        else
        {
            Read-Key "Press any Key to End console."
        }

        exit
    }
}

#Sample Execution
#Main -SourceUserName hogehoge.ActiveDirectory -TargetUserName fugafuga
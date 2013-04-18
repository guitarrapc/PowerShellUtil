#Requires -Version 2.0

param
(
    [Parameter(
    HelpMessage = @"
    Input path of CREATE TABLE sql file. If blank then './tablemaster.txt' will use.
    Sample text requires to be pastes.

CREATE TABLE `test_table` (
	`id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT, COMMENT 'IDだよ！',
	`result` INT(10) NOT NULL DEFAULT '0' COMMENT '結果。0 = 未、1 = 勝利、2 = 敗退',
	`created` DATETIME NOT NULL,
	`modified` DATETIME NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `	result` (`result`)
)
COMMENT='テストだよ！'
COLLATE='utf8_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=0;

"@,
    Position = 0,
    Mandatory = $false,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({Test-Path $_.FullName})]
    [IO.FileInfo[]]
    $InputPath = ".\table_master.txt",

    [Parameter(
    HelpMessage = @"
    Output path of converted csv file. If blank then If blank then 'tablename.csv' will create.
    Sample converted csv.

test_table
テストだよ！
IDだよ！, 結果。0 = 未、1 = 勝利、2 = 敗退, , , ,
id, result, created, modified, id,

"@,
    Position = 1,
    Mandatory = $false,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true
    )]
    [ValidateNotNullOrEmpty()]
    $OutputPath
    )

function Get-ColumnCommentSQL{

    [CmdletBinding(  
        SupportsShouldProcess = $false,
        ConfirmImpact = "none",
        DefaultParameterSetName = ""
    )]
    param
    (
        [Parameter(
        HelpMessage = @"
        Input path of CREATE TABLE sql file. If blank then './tablemaster.txt' will use.
        Sample text requires to be pastes.

CREATE TABLE `test_table` (
	`id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT, COMMENT 'IDだよ！',
	`result` INT(10) NOT NULL DEFAULT '0' COMMENT '結果。0 = 未、1 = 勝利、2 = 敗退',
	`created` DATETIME NOT NULL,
	`modified` DATETIME NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `	result` (`result`)
)
COMMENT='テストだよ！'
COLLATE='utf8_unicode_ci'
ENGINE=InnoDB
AUTO_INCREMENT=0;
"@,
        Position = 0,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_.FullName})]
        [IO.FileInfo[]]
        $InputPath = ".\table_master.txt",

        [Parameter(
        HelpMessage = @"
        Output path of converted csv file. If blank then If blank then 'tablename.csv' will create.
        Sample converted csv.

test_table
テストだよ！
IDだよ！, 結果。0 = 未、1 = 勝利、2 = 敗退, , , ,
id, result, created, modified, id,
"@,
        Position = 1,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        $OutputPath
     )
 
    begin
    {
        # initialize String Array
        [string[]]$hoge = [string[]]$moge = [string[]]$fuga = [string[]]$foo = $null

        # Check previous csv files are existing or not.
        if (Test-Path .\*.csv)
        {
            Remove-Item -Path ./*.csv -Confirm -Force
        }

    }

    process
    {

        # Get Table Name
        $TableName = Get-Content -Path $InputPath -Encoding Default `
            | ?{ 
                $_ -cmatch "^CREATE TABLE [``](?<TableName>.*)[``].*"
                } `
            | %{
                $Matches.TableName
            }

        # Get Table Comments
        $TableComment = Get-Content -Path $InputPath -Encoding Default `
            | ?{ 
                $_ -cmatch "^COMMENT='(?<TableComment>.*)'"
                } `
            | %{
                $Matches.TableComment
            }


        # Get Column Name and Comments
        $ColumnResult = Get-Content -Path $InputPath -Encoding Default `
            | ?{ $_ -match "[' ']*.*," } `
            | %{
                    $_ -match "[``].*[``].*'(?<ColumnComment>.*)'" > $null
                    $ColumnComment = $Matches.ColumnComment
                    $_ -match "[``](?<Column>.*)[``].*" > $null
                    $Column = $Matches.Column

                    [PSCustomObject]@{
                    Column = $Column
                    ColumnComment = $Columncomment
                    }
                } 
        }

    end
    {

        # add conmma to each columns
        $hoge += $ColumnResult | %{[string]$_.ColumnComment + ","}
        $moge += $ColumnResult | %{[string]$_.Column + ","}

        #region output parameters definition
        $AppendOutputOptions = @{
            Append = $true
            Encoding = "default"
            NoClonner = $true
            Force = $true
        }

        $NoAppendOutputOptions = @{
            Append = $false
            Encoding = "default"
            NoClonner = $true
            Force = $true
        }
        #endregion
        

        #region Export files to csv (Could not use Export-Csv as using "" to pickup ArrayStrings)
        switch ($true){
        {$OutputPath -ne $null} {   
            "$TableName" | Out-File -FilePath $OutputPath -Encoding default -NoClobber -Force
            "$TableComment" | Out-File -FilePath $OutputPath -Encoding default -NoClobber -Force -Append
            "$hoge" | Out-File -FilePath $OutputPath -Encoding default -NoClobber -Force -Append
            "$moge" | Out-File -FilePath $OutputPath -Encoding default -NoClobber -Force -Append
            }

        default {
            "$TableName" | Out-File -FilePath "$($TableName).csv" -Encoding default -NoClobber -Force
            "$TableComment" | Out-File -FilePath "$($TableName).csv" -Encoding default -NoClobber -Force -Append
            "$hoge" | Out-File -FilePath "$($TableName).csv" -Encoding default -NoClobber -Force -Append
            "$moge" | Out-File -FilePath "$($TableName).csv" -Encoding default -NoClobber -Force -Append
            }
        }
        #endregion

    }
}

Get-ColumnCommentSQL
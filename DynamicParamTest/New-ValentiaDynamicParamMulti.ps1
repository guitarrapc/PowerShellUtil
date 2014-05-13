#Requires -Version 3.0

#-- function helper for Dynamic Param --#

<#
.SYNOPSIS 
This cmdlet will return Dynamic param dictionary

.DESCRIPTION
You can use this cmdlet to define Dynamic Param

.EXAMPLE
function Show-DynamicParamMulti
{
    [CmdletBinding()]
    param(
        [parameter(position = 6)]
        $nyao
    )
    
    dynamicParam
    {
        $dynamicParams = (
            @{Mandatory    = $true
              name         = "hoge"
              Options      = "hoge","piyo"
              position     = 0
              Type         = "System.String[]"
              validateSet  = $true
              valueFromPipelineByPropertyName = $true},
              
              @{Mandatory    = $true
              name         = "foo"
              Options      = 1,2,3,4,5
              position     = 1
              Type         = "System.Int32[]"
              validateSet  = $true},

              @{DefaultValue = (4,2,5)
              Mandatory    = $false
              name         = "bar"
              Options      = 1,2,3,4,5
              position     = 2
              Type         = "System.Int32[]"
              validateSet  = $false}
        )

        $dynamic = New-DynamicParamMulti -dynamicParams $dynamicParams
        return $dynamic
    }

    begin
    {
    }
    process
    {
        $PSBoundParameters.hoge
        $PSBoundParameters.foo
        if ($PSBoundParameters.ContainsKey('bar'))
        {
            $PSBoundParameters.bar
            $PSBoundParameters.bar.GetType().FullName
        }
        else
        {
            $bar = $dynamic.bar.Value
            $bar
            $bar.GetType().FullName
        }
    }
}

"Test 1 ---------------------"
Show-DynamicParamMulti -hoge hoge -foo 1,2,3,4
"Test 2 ---------------------"
Show-DynamicParamMulti -hoge piyo -foo 2 -bar 2
#>

function New-DynamicParamMulti
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 1,
            position = 0,
            valueFromPipeline = 1,
            valueFromPipelineByPropertyName = 1)]
        [hashtable[]]
        $dynamicParams
    )

    begin
    {
        $dynamicParamLists = New-DynamicParamList -dynamicParams $dynamicParams
        $dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    }

    process
    {
        foreach ($dynamicParamList in $dynamicParamLists)
        {
            # create attributes
            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.ParameterSetName = "__AllParameterSets"
            (
                "helpMessage",
                "mandatory",
                "parameterSetName",
                "position",
                "valueFromPipeline",
                "valueFromPipelineByPropertyName",
                "valueFromRemainingArguments"
            ) `
            | %{
                if($dynamicParamList.$_)
                {
                    $attributes.$_ = $dynamicParamList.$_
                }
            }

            # create attributes Collection
            $attributesCollection = New-Object 'Collections.ObjectModel.Collection[System.Attribute]'
            $attributesCollection.Add($attributes)
        
            # create validation set
            if ($dynamicParamList.validateSet)
            {
                $validateSetAttributes = New-Object System.Management.Automation.ValidateSetAttribute $dynamicParamList.options
                $attributesCollection.Add($validateSetAttributes)
            }

            # Set default type or get from dynamicparam
            # Priority
            # 1. Type KV
            # 2. Type of DefaultValue
            # 3. System.Object[]
            if ($dynamicParamList.type)
            {
                $type = [Type]::GetType($dynamicParamList.Type)
            }
            else
            {
                if ($dynamicParamList.defaultValue)
                {
                    $DefaultValueType = $dynamicParamList.defaultValue.GetType().FullName
                    $type = [Type]::GetType($DefaultValueType)
                }
                else
                {
                    $type = [Type]::GetType("System.Object[]")
                }
            }

            if ($null -eq $type)
            {
                throw "type not defined or Null exception! Make sure you have set fullname for the type : '{0}'" -f $dynamicParamList.type
            }

            # create RuntimeDefinedParameter
            $runtimeDefinedParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter @($dynamicParamList.name, $type, $attributesCollection)

            # Set Default Value if passed
            if ($dynamicParamList.defaultValue)
            {
                if ($dynamicParamList.defaultValue -is $type)
                {
                    $runtimeDefinedParameter.Value = $dynamicParamList.defaultValue
                }
                elseif ($dynamicParamList.defaultValue -as $type)
                {
                    Write-Verbose ("Convert Type for ParameterName '{0}'. DefaultValue '{1}' convert from '{2}' to '{3}'" `
                        -f 
                            $dynamicParamList.name,
                            $dynamicParamLists.defaultValue,
                            $dynamicParamList.defaultValue.GetType().FullName,
                            $type)
                    $runtimeDefinedParameter.Value = $dynamicParamList.defaultValue -as $type
                }
                else
                {
                    throw "Cannot convert Type for ParameterName '{0}'. DefaultValue '{1}' could not convert from '{2}' to '{3}'" `
                        -f 
                            $dynamicParamList.name,
                            $dynamicParamLists.defaultValue,
                            $dynamicParamList.defaultValue.GetType().FullName,
                            $type
                }
            }

            # create Dictionary
            $dictionary.Add($dynamicParamList.name, $runtimeDefinedParameter)
        }
    }

    end
    {
        # return result
        return $dictionary
    }
}


<#
.SYNOPSIS 
This cmdlet will return Dynamic param list item for dictionary

.DESCRIPTION
You can pass this list to DynamicPramMulti to create Dynamic Param
#>
function New-DynamicParamList
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 1,
            position = 0,
            valueFromPipeline = 1,
            valueFromPipelineByPropertyName = 1)]
        [hashtable[]]
        $dynamicParams
    )

    begin
    {
        # create generic list
        $list = New-Object System.Collections.Generic.List[HashTable]

        # create key check array
        [string[]]$keyCheckInputItems = "helpMessage", "mandatory", "name", "parameterSetName", "options", "position", "valueFromPipeline", "valueFromPipelineByPropertyName", "valueFromRemainingArguments", "validateSet", "Type", "DefaultValue"

        $keyCheckList = New-Object System.Collections.Generic.List[String]
        $keyCheckList.AddRange($keyCheckInputItems)

        # sort dynamicParams hashtable by position
        $newDynamicParams = Sort-DynamicParamHashTable -dynamicParams $dynamicParams
    }

    process
    {
        foreach ($dynamicParam in $newDynamicParams)
        {
            $invalidParamter = $dynamicParam.Keys | where {$_ -notin $keyCheckList}
            if ($($invalidParamter).count -ne 0)
            {
                throw ("Invalid parameter '{0}' found. Please use parameter from '{1}'" -f $invalidParamter, ("$keyCheckInputItems" -replace " "," ,"))
            }
            else
            {
                if (-not $dynamicParam.Keys.contains("name"))
                {
                    throw ("You must specify mandatory parameter '{0}' to hashtable key." -f "name")
                }
                elseif (-not $dynamicParam.Keys.contains("options"))
                {
                    throw ("You must specify mandatory parameter '{0}' to hashtable key." -f "options")
                }
                else
                {
                    $list.Add($dynamicParam)
                }
            }
        }
    }

    end
    {
        return $list
    }
}


function Sort-DynamicParamHashTable
{
    [CmdletBinding()]
    param
    (
        [parameter(
            mandatory = 1,
            position = 0,
            valueFromPipeline = 1,
            valueFromPipelineByPropertyName = 1)]
        [hashtable[]]
        $dynamicParams
    )

    begin
    {
        # get max number of position for null position item
        $max = ($dynamicParams.position | measure -Maximum).Maximum
    }

    process
    {
        # output PSCustomObject[Name<SortedPosition>,Value<DynamicParamHashTable>]. posision is now sorted.
        $h = $dynamicParams `
        | %{
            $history = New-Object System.Collections.Generic.List[int]
            $hash = @{}
            
            # temp posision for null item. This set as (max + number of collection items)
            $num = $max + $parameters.Length
        }{
            Write-Verbose ("position is '{0}'." -f $position)
            $position = $_.position
            
            #region null check
            if ($null -eq $position)
            {
                Write-Verbose ("position is '{0}'. set current max index '{1}'" -f $position, $num)
                $position = $num
                $num++
            }
            #endregion

            #region dupricate check
            if ($position -notin $history)
            {
                Write-Verbose ("position '{0}' not found in '{1}'. Add to history." -f $position, ($history -join ", "))
                $history.Add($position)
            }
            else
            {
                $changed = $false
                while ($position -in $history)
                {
                    Write-Verbose ("position '{0}' found in '{1}'. Start increment." -f $position, ($history -join ", "))
                    $position++
                    $changed = $true
                }
                Write-Verbose (" incremented position '{0}' not found in '{1}'. Add to history." -f $position, ($history -join ", "))
                if ($changed){$history.Add($position)}
            }
            #endregion

            #region set temp hash
            Write-Verbose ("Set position '{0}' as name of temp hash." -f $position)
            $hash."$position" = $_
            #endregion
        }{[PSCustomObject]$hash}
    }

    end
    {
        # get index for each object
        $index = [int[]](($h | Get-Member -MemberType NoteProperty).Name) | sort
        
        # return sorted hash order by index
        return $index | %{$h.$_}
    }
}


function Show-DynamicParamMulti
{
    [CmdletBinding()]
    param(
        [parameter(position = 6)]
        $nyao
    )
    
    dynamicParam
    {
        $dynamicParams = (
            @{Mandatory    = $true
              name         = "hoge"
              Options      = "hoge","piyo"
              position     = 0
              Type         = "System.String[]"
              validateSet  = $true
              valueFromPipelineByPropertyName = $true},
              
              @{Mandatory    = $true
              name         = "foo"
              Options      = 1,2,3,4,5
              position     = 1
              Type         = "System.Int32[]"
              validateSet  = $true},

              @{DefaultValue = (4,2,5)
              Mandatory    = $false
              name         = "bar"
              Options      = 1,2,3,4,5
              position     = 2
              Type         = "System.Int32[]"
              validateSet  = $false}
        )

        New-DynamicParamMulti -dynamicParams $dynamicParams
    }

    begin
    {
    }
    process
    {
        $PSBoundParameters.hoge
        $PSBoundParameters.foo
        if ($PSBoundParameters.ContainsKey('bar'))
        {
            $PSBoundParameters.bar
            $PSBoundParameters.bar.GetType().FullName
        }
        else
        {
            $bar = $dynamic.bar.Value
            $bar
            $bar.GetType().FullName
        }
    }
}

"Test 1 ---------------------"
Show-DynamicParamMulti -hoge hoge -foo 1,2,3,4
"Test 2 ---------------------"
Show-DynamicParamMulti -hoge piyo -foo 2 -bar 2
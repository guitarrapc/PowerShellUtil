function New-ValentiaDynamicParam
{
    param
    (
        [parameter(
            mandatory = 1,
            position = 0)]
        [string]
        $name,

        [parameter(
            mandatory = 1,
            position = 1)]
        [string[]]
        $options,

        [parameter(
            mandatory = 0,
            position = 2)]
        [switch]
        $mandatory,

        [parameter(
            mandatory = 0,
            position = 3)]
        [string]
        $setName="__AllParameterSets",

        [parameter(
            mandatory = 0,
            position = 4)]
        [int]
        $position,

        [parameter(
            mandatory = 0,
            position = 5)]
        [switch]
        $valueFromPipelineByPropertyName,

        [parameter(
            mandatory = 0,
            position = 6)]
        [string]
        $helpMessage,

        [parameter(
            mandatory = 0,
            position = 7)]
        [switch]
        $validateSet = $false
    )

    # create attributes
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = $SetName
    if($mandatory){$attributes.Mandatory = $true}                                             # mandatory
    if($position -ne $null){$attributes.Position=$position}                                   # position
    if($valueFromPipelineByPropertyName){$attributes.ValueFromPipelineByPropertyName = $true} # valueFromPipelineByPropertyName
    if($helpMessage){$attributes.HelpMessage = $helpMessage}                                  # helpMessage

    # create attributes Collection
    $attributesCollection = New-Object 'Collections.ObjectModel.Collection[System.Attribute]'
    $attributesCollection.Add($attributes)
    # create validation set
    if ($validateSet)
    {
        $validateSetAttributes = New-Object System.Management.Automation.ValidateSetAttribute $options
        $attributesCollection.Add($validateSetAttributes)
    }

    # create RuntimeDefinedParameter
    $runtimeDefinedParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter @($name, [System.String], $attributesCollection)

    # create Dictionary
    $dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $dictionary.Add($name, $runtimeDefinedParameter)

    # return result
    return $dictionary
}

function Show-Free
{
    [CmdletBinding()]
    Param
    (
    )

    DynamicParam
    {
        New-ValentiaDynamicParam -name Drive -options @(gwmi win32_volume |%{$_.driveletter}|sort) -Position 0 -validateSet
    }

    begin
    {
        $drive = $PSBoundParameters.drive
    }
    process
    {
        $drive
    }

}

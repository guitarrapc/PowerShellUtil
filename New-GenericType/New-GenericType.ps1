function New-GenericType{

    [CmdletBinding()]
    param(
        [parameter(
            position = 0,
            mandatory,
            helpMessage = "Input Generic Class Name you want to create")]
        [string]
        $className,

        [parameter(
            position = 1,
            mandatory,
            helpMessage = "Input Generic Class type parameter")]
        [string[]]
        $typeParameters,

        [parameter(
            position = 2,
            mandatory = 0,
            helpMessage = "Input Constructor parameter you want to assign to Generic Class")]
        [object[]]
        $constructorParameters,

        [parameter(
            position = 2,
            mandatory = 0,
            helpMessage = "Input Class name of Generic")]
        [string]
        $typeName = "System.Collections.Generic"
    )

    try
    {
        [Type]$genericTypeName = $typeName + "." + $className + '`' + $typeParameters.Count
        $closedtype = $genericTypeName.MakeGenericType([Type[]]$typeParameters)
        $geneticInstance = ,[Activator]::CreateInstance($closedType, $constructorParameters)
        return $geneticInstance
    }
    catch
    {
        throw $_
    }

}

$list = New-GenericType -className List -typeParameters "System.String"
$list.GetType().FullName

$dic = New-GenericType -className Dictionary -typeParameters ("System.String","System.String")
$dic.GetType().FullName
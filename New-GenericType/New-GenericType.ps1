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
        ,[Activator]::CreateInstance($closedType, $constructorParameters)
    }
    catch
    {
        throw $_
    }

}
$list = New-GenericType -className List -typeParameters "System.String"
$list.GetType().Fullname

$dic = New-GenericType -className Dictionary -typeParameters ("System.String",$list.GetType().FullName)
$dic.GetType().Fullname

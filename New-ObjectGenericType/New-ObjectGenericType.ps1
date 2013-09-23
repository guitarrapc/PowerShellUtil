function New-ObjectGenericType{

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
            position = 3,
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


# sample
$list = New-GenericType -className List -typeParameters "string"
$list.GetType().Fullname # System.Collections.Generic.List`1[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]

$dic = New-GenericType -className Dictionary -typeParameters ("string",$list.GetType().FullName)
$dic.GetType().Fullname # System.Collections.Generic.Dictionary`2[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.Collections.Generic.List`1[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]

$dic = New-GenericType -className Dictionary -typeParameters ("string",$list.GetType().FullName)
$dic.GetType().Fullname # System.Collections.Generic.Dictionary`2[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.Collections.Generic.List`1[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]

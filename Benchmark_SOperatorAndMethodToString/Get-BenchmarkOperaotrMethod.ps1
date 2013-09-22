function Get-StringForeachTest{
 
    param(
    $int
    )
 
    [string]$string  = ""
 
    measure-Command{
        foreach ($i in $int)
        {
            $addString = "hello $i"
            $string += $addString
        }

        $string
    }

    # $string.GetType().FullName
}


function Get-ArrayForeachTest{
 
    param(
    $int
    )
 
    [string[]]$array  = @()
 
    measure-Command{
        foreach ($i in $int)
        {
            $addString = "hello $i"
            $array += $addString
        }

        $array
    }

    # $array.GetType().FullName

}


function Get-ArrayListForeachTest{
 
    param(
    $int
    )
 
    $arraylist  = New-Object System.Collections.ArrayList


    measure-Command{
        foreach ($i in $int)
        {
            $addString = "hello $i"
            $arraylist　+= $addString
        }
        
        $arraylist
    }

    # $arraylist.GetType().FullName
}



function Get-ListForeachTest{
 
    param(
    $int
    )
 
    $list  = New-Object 'System.Collections.Generic.List[System.String]'
 
    measure-Command{
        foreach ($i in $int)
        {
            $addString = "hello $i"
            $list += $addString
        }

        $list
    }

    # $list.GetType().FullName
}



function Get-ArrayListAddForeachTest{
 
    param(
    $int
    )
 
    $arraylist  = New-Object System.Collections.ArrayList

    Measure-Command{ 
        foreach ($i in $int)
        {
            $addString = "hello $i"
            $arraylist.Add($addString) > $null
        }

        $arraylist.ToArray()
    }

    # $arraylist.GetType().FullName
}


function Get-ListAddForeachTest{
 
    param(
    $int
    )
 
    $list  = New-Object 'System.Collections.Generic.List[System.String]'
 
    measure-Command{
        foreach ($i in $int)
        {
            $addString = "hello $i"
            $list.Add($addString)
        }

        $list.ToArray()
    }

    # $list.GetType().FullName
}



function Get-StringBuilderForeachTest{
 
    param(
    $int
    )
 
    $stringBuilder = New-Object System.Text.StringBuilder
 
    Measure-Command{
        foreach ($i in $int)
        {
            $addString = "hello $i"
            $stringBuilder.Append($addString) > $null
        }

        $stringBuilder.ToString()
    }
    
    # $stringBuilder.GetType().FullName
}







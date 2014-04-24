#100..200 | %{$i=0;$divide = 30}{$i++;if($i -le $divide){$_}else{$divide= $divide+30;"-----"}} | %{"hoge$_"}

filter Filter-BufferScriptBlock
{
    param
    (
        [int]
        $Count,

        [type]
        $Type,

        [ScriptBlock]
        $ScriptBlock,

        [object]
        $ArgumentList
    )

    begin
    {
        $initial = $Count
        $i = 0
        $list = New-Object "System.Collections.Generic.List[$type]"
    }

    process
    {
        $i++
        if ($i -le $Count)
        {
            $list.Add($_)
            sleep -Milliseconds 100
        }
        else
        {
            $list.Add($_)
            &$ScriptBlock -ArgumentList $argumentList -list $list

            # move next
            $Count = $Count + $initial

            #clear current
            $list.Clear()
        }
    }

    end
    {
        &$ScriptBlock -ArgumentList $argumentList -list $list
    }
}

#100..200 | %{"10.0.0.$_"} | buffer -count 30 -type ipaddress[] -ScriptBlock {param($ArgumentList, $list) "{0} : $(&$ArgumentList)" -f "$($list.IPAddressToString)"} -ArgumentList ({Get-Date})
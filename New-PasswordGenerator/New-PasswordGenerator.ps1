function New-PasswordGenerator
{
<#
.Synopsis
   Generate Password with desired length and pattern
.DESCRIPTION
   You can select length and pattern of password.
   1. [plain] as charactors(a-z, A-Z) only.
   2. [medium] as charactors(a-z, A-Z) and numbers(0-9).
   2. [complex] as charactors(a-z, A-Z), numbers(0-9) and Symbols (~!@#$%^&*_-+=`|\(){}[]:;"''<>,.?/).
.EXAMPLE
    New-PasswordGenerator -length 12
    # create plain password for length 12
.EXAMPLE
    New-PasswordGenerator -length 12 -medium
    # create charactor and number password for length 12
.EXAMPLE
    New-PasswordGenerator -length 12 -complex
    # create charactor, number and symbol password for length 12
#>

    [CmdletBinding(DefaultParameterSetName = "plain")]
    param
    (
        [parameter(
            mandatory,
            position = 0)]
        [int]
        $length,

        # with Uppercase Letters, Lowercase Letters
        [parameter(
            mandatory = 0,
            position = 1,
            ParameterSetName="plain")]
        [switch]
        $plain,

        # with Uppercase Letters, Lowercase Letters, Numbers
        [parameter(
            mandatory = 0,
            position = 1,
            ParameterSetName="medium")]
        [switch]
        $medium,

        # with Uppercase Letters, Lowercase Letters, Numbers, Symbols
        [parameter(
            mandatory = 0,
            position = 1,
            ParameterSetName="complex")]
        [switch]
        $complex
    )

    # create string builder
    $sb = New-Object System.text.StringBuilder

    # default plain values
    $sb.Append('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ') > $null  
    
    # append if medium switch
    if ($PSBoundParameters.medium.IsPresent -or $PSBoundParameters.complex.IsPresent)
    {
        Write-Verbose "Append Numbers to password seed"
        $sb.Append('0123456789') > $null
    }
    
    # append if complex switch
    if ($PSBoundParameters.complex)
    {
        Write-Verbose "Append Symbols to password seed"
        $sb.Append('~!@#$%^&*_-+=`|\(){}[]:;"''<>,.?/') > $null
    }
    
    Write-Verbose "create password string"
    $password = -join ([System.Linq.Enumerable]::ToArray($sb.ToString()) | Get-Random -count $length)

    Write-Verbose "convert each charactor to phoenix code"
    [System.Linq.Enumerable]::ToArray($password) `
    | %{
        switch ($_)
        {
            a	    {$word = "alpha"   }
            b	    {$word = "bravo"   }
            c	    {$word = "charlie" }
            d	    {$word = "delta"   }
            e	    {$word = "echo"    }
            f	    {$word = "foxtrot" }
            g	    {$word = "golf"    }
            h	    {$word = "hotel"   }
            i	    {$word = "india"   }
            j	    {$word = "juliett" }
            k	    {$word = "kilo"    }
            l	    {$word = "lima"    }
            m	    {$word = "mike"    }
            n	    {$word = "november"}
            o	    {$word = "oscar"   }
            p	    {$word = "papa"    }
            q	    {$word = "quebec"  }
            r	    {$word = "romeo"   }
            s	    {$word = "sierra"  }
            t	    {$word = "tango"   }
            u	    {$word = "uniform" }
            v	    {$word = "victor"  }
            w	    {$word = "whiskey" }
            x	    {$word = "xray"    }
            y	    {$word = "yankee"  }
            z	    {$word = "zulu"    }
            1	    {$word = "one"     }
            2	    {$word = "two"     }
            3	    {$word = "three"   }
            4	    {$word = "four"    }
            5	    {$word = "five"    }
            6	    {$word = "six"     }
            7	    {$word = "seven"   }
            8	    {$word = "eight"   }
            9	    {$word = "nine"    }
            0	    {$word = "zero"    }
            default {$word = $_        }
        }

        # check except symbols
        if ($_ -ne $word)
        {
            # convert to Upper case phoenix
            if ($_ -cmatch ([string]$_).ToUpper())
            {
                $word = $word.ToUpper()
            }
        }
        
        # show phoenix code in single line
        Write-Host ("{0} " -f $word) -ForegroundColor DarkGray -NoNewLine
    }

    # add blank new line
    Write-Host ("{0}" -f [System.Environment]::NewLine)

    Write-Verbose "output password into host"
    return $password
}
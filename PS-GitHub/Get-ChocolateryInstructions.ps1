#Requires -Version 3.0

function Get-ChocolateryInstructions{
@"

    You can use chocolatey to install packages!!
    ------------------------------------------------------------------
    - clist : Search packages from http://chocolatey.org/packages
        i.e. Search hoge will be....
    
        clist hoge

    ------------------------------------------------------------------
    - cinst : Install packages from http://chocolatey.org/packages
        i.e. Install hoge will be....
    
        cinst hoge

    ------------------------------------------------------------------
    - cuinst : Uninstall package 
        i.e. Uninstall hoge will be....
    
        cuninst hoge
    
    ------------------------------------------------------------------
    - cup : update package
        i.e. Update hoge will be....

        cup hoge

        i.e. Update all package wil be.....

        cup all

    ------------------------------------------------------------------
    - cver : Check packages installed

    ------------------------------------------------------------------
"@
}
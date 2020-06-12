#42
1..100|%{@('Fizz')[$_%3]+{Buzz}[$_%5]??$_}

#42 can't be treat `r as CR on codegolf
1..100|%{"$_`r"+{Fizz}[$_%3]+{Buzz}[$_%5]}

#45
1..100|%{@('Fizz')[$_%3]+@('Buzz')[$_%5]??$_}

#46 can't be treat `r as CR on codegolf
1..100|%{"$_`r"+'Fizz'*!($_%3)+'Buzz'*!($_%5)}

#48 can't be treat `r as CR on codegolf
1..100|%{"$_`r"+@("Fizz")[$_%3]+@("Buzz")[$_%5]}

#50 "" + {Fizz}[0] = Fizz. {ANY} will convert to [string] if left is [string], also can be null.
1..100|%{($t=""+{Fizz}[$_%3]+{Buzz}[$_%5])?$t :$_}

#51 "Fizz"*$true = Fizz
1..100|%{($t='Fizz'*!($_%3)+'Buzz'*!($_%5))?$t :$_}

#53
1..100|%{(($t=""+{Fizz}[$_%3]+{Buzz}[$_%5]),$_)[!$t]}

#53
1..100|%{($_,(""+{Fizz}[$_%3]+{Buzz}[$_%5])|sort)[1]}

#54
1..100|%{$_%15?$_%3?$_%5?$_ :'Buzz':'Fizz':'FizzBuzz'}

#54
1..100|%{$t=$_%3?"":"Fizz";$_%5?$t ?$t :$_ :$t+"Buzz"}

#54
1..100|%{(($t="Fizz"*!($_%3)+"Buzz"*!($_%5)),$_)[!$t]}

#54
1..100|%{($_,('Fizz'*!($_%3)+'Buzz'*!($_%5))|sort)[1]}

#55
1..100|%{$t=$_%3?'':'Fizz';$_%5?$_%3?$_ :$t :$t+'Buzz'}

#55
1..100|%{($p=($_%3?"":"Fizz")+($_%5?"":"Buzz"))?$p :$_}

#58 @('Fizz')[$_%3] = [string] or null.
1..100|%{$($t=@("Fizz")[$_%3]+@("Buzz")[$_%5]);$t ?$t :$_}

#60
1..100|%{$t="$($_%3?'':'Fizz')$($_%5?'':'Buzz')";$t ?$t :$_}
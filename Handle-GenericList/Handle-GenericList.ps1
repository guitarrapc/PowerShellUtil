# PowerShell List Execution Sample

# Create Generic List
$list = New-Object 'System.Collections.Generic.List[System.String]'

# Add items to list
$list.Add("a")
$list.Add("b")
$list.Add("c")
$list.Add("d")
$list.Add("a")
$list.Add("a")
$list.Add("a")


# Add range of items
$list.AddRange([string[]]@("e","f","g","h")) # make sure type match for list


# find matched item of System.Predicate using ScriptBlock (anonymous delegates)
$list.Find({$args -eq "a"})  # return a
$list.Find({$args -ceq "A"}) # nothing return
$list.Find({$args -eq "Z"})  # nothing return

# find from last for an item of System.Predicate using ScriptBlock (anonymous delegates)
$list.FindLast({$args[0] -eq "c"}) # return c

# find all matched item of System.Predicate using ScriptBlock (anonymous delegates)
$list.FindAll({$args[0] -eq "a"}) # find all a
$list | where {$_ -eq "a"}

# find index for matched item from specific index to last index. item created is System.Predicate using ScriptBlock (anonymous delegates)
$list.FindIndex(0,{$args[0] -eq "a"}) # retrun index 0
$list.FindIndex(1,{$args[0] -eq "a"}) # retrun index 5

# find index of item start from last record
$list.FindLastIndex({$args[0] -eq "a"})


# insert item to specific index
$list.Insert(2,"f") # f will insert to index 2


# list up current items
$list


# Remove method for first match item
$list.Remove("a") # delete first a

# Removeall with create System.Predicate using ScriptBlock (anonymous delegates)
$list.RemoveAll({$args[0] -eq "a"}) # delete all a

# RemoveAt method to delete specific index item
$list.RemoveAt(0) # delete b

# RemoveRange method to delete specific range items
$list.RemoveRange(0,1) # delete c and d


# check item is exist or not
$list.Contains("f") #true
$list.Contains("a") #false


# clear list
$list.Clear()
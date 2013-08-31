function Get-ADUserAttributes{

    [CmdletBinding()]
    param(
        [parameter(
        position = 0,
        mandatory = 1)]
        [string[]]
        $users
    )

    foreach ($user in $users)
    {
        $search = New-Object DirectoryServices.DirectorySearcher([ADSI]“”)
        $search.filter = “(&(objectClass=user)(displayName=$user))”
        $results = $search.Findall()

        foreach($result in $results)
        {
            $userEntry = $result.GetDirectoryEntry()
            "$($userEntry.displayName):$($userEntry.sAMAccountName)"
            $userEntry | select *
        }
    }
}

$users = @(
"guitarrapc hogehoge"
)

Get-ADUserAttributes -users $users
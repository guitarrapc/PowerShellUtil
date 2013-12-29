# 1. Simple Query
Invoke-RestMethod -uri "https://gdata.youtube.com/feeds/api/videos?v=2&q=Desired+State+Configuration+PowerShell" | clip

# 2. Filter Object
Invoke-RestMethod -uri "https://gdata.youtube.com/feeds/api/videos?v=2&q=DSC+PowerShell" `
    | %{[PSCustomObject]@{
        Title = $_.title
        Published = $_.published
        Updated   = $_.Updated
        Author = $_.author.name
        Link = $_.content.src
    }} `
    | sort Published -Descending | clip


# 3. Declare how collection filtering required
filter Filter-YoutubeApi
{
    [PSCustomObject]@{
        Title     = [string]$_.title
        Published = [datetime]$_.published
        Updated   = [datetime]$_.Updated
        Author    = [string]$_.author.name
        Link      = [uri]$_.content.src
    }
}

# simplify collection filtering
Invoke-RestMethod -uri "https://gdata.youtube.com/feeds/api/videos?v=2&q=DSC+PowerShell" `
    | Filter-YoutubeApi `
    | sort Published -Descending `
    | Format-List
# define
$path = "d:\s3upload"
$s3bucketname = "public"

# upload file to s3
Get-ChildItem -Path $path `
    | %{
        Write-S3Object -BucketName $s3bucketname -File $_.Name -Key $_.Name -CannedACLName PublicRead
    }


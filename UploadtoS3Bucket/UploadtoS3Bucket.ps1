# define
$path = "D:\test.ps1"
$s3bucketname = "publictest"
$expiredate = "2013/12/31"

try
{
    # new bucketname
    if (-not(Get-S3Bucket -BucketName $s3bucketname))
    {
        New-S3Bucket -BucketName $s3bucketname
    }

    # upload file to s3
    $file = Get-ChildItem -Path $path
    if (-not(Get-S3Object))
    {
        Write-S3Object -BucketName $s3bucketname -File $file.FullName -Key $file.Name -CannedACLName PublicRead
    }
    else
    {
        Write-Error ("S3 bucket name {0} already contains key name {1}, escape from overwrite. Please check file name to upload." -f $s3bucketname,$file.name)
    }

    # get s3 object
    Invoke-RestMethod -Method Get -Uri (Get-S3PreSignedURL -BucketName $s3bucketname -Key $file.Name -Expires $expiredate) -OutFile ("d:\" + $file.BaseName + 2 + $file.Extension )
    (Get-S3PreSignedURL -BucketName $s3bucketname -Key $file.Name -Expires "2013/12/31")
}
catch
{
    throw $_
}
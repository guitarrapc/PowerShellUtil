function Get-PSCredential{

    [CmdletBinding()]
    param(
    [parameter(
        position = 0,
        mandatory = 0)]
    $credentialpath = "C:\Deployment\Bin\credential.json"
    )

    $credential = Get-Content $credentialpath -Raw | ConvertFrom-Json
    $secpasswd = ConvertTo-SecureString $credential.password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($($credential.user), $secpasswd)    

    return $credential
}


function New-PSCredential{

    [CmdletBinding()]
    param(
    [parameter(
        position = 0,
        mandatory = 0)]
    $credentialpath = "C:\Deployment\Bin\credential.json",

    [parameter(
        position = 1,
        mandatory)]
    $user,

    [parameter(
        position = 2,
        mandatory)]
    $password
    )

    [PSCustomObject]@{
        user = $user
        password = $password
    } | ConvertTo-Json | Out-File -FilePath $credentialpath -Force

}


New-PSCredential -user ec2-user -password Qwe09r7c23
Get-PSCredential
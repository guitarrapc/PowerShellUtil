function New-CreateOSUser{

# Create New Local User for Deployment
#
# - SAMPLE1 (Recommend - Secure Input)
#   New-valentiaOSUser
#   (* secure prompt will up and mask your PASSWORD input as *****.)
#
# - SAMPLE2 (NOT-Recommend - Unsecure Input)
#   New-valentiaOSUser -Password "1231231qawerqwe87$%"
#


# User Flag Property Samples
#  0X10040
#
#  Run LogOn Script　&H0001
#  ADS_UF_SCRIPT  =  0X0001
#
#  Account Disable　&H0002
#  ADS_UF_ACCOUNTDISABLE =  0X0002
#
#  Account requires Home Directory　&H0008
#  ADS_UF_HOMEDIR_REQUIRED =  0X0008
#
#  Account Lockout　&H0010
#  ADS_UF_LOCKOUT =  0X0010
#
#  No Password reqyured for account　&H0020
#  ADS_UF_PASSWD_NOTREQD =  0X0020
#
#  No change Password　&H0040
#  ADS_UF_PASSWD_CANT_CHANGE =  0X0040
#
#  Allow Encypted Text Password　&H0080
#  ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED  =  0X0080
#
#  ADS_UF_TEMP_DUPLICATE_ACCOUNT =  0X0100
#  ADS_UF_NORMAL_ACCOUNT  =  0X0200
#  ADS_UF_INTERDOMAIN_TRUST_ACCOUNT =  0X0800
#  ADS_UF_WORKSTATION_TRUST_ACCOUNT =  0X1000
#  ADS_UF_SERVER_TRUST_ACCOUNT  =  0X2000
#
#  Password infinit　&H10000
#  ADS_UF_DONT_EXPIRE_PASSWD =  0X10000
#
#  ADS_UF_MNS_LOGON_ACCOUNT =  0X20000
#
#  Smart Card Required　&H40000
#  ADS_UF_SMARTCARD_REQUIRED  =  0X40000
#
#  ADS_UF_TRUSTED_FOR_DELEGATION =  0X80000
#  ADS_UF_NOT_DELEGATED =  0X100000
#  ADS_UF_USE_DES_KEY_ONLY = 0x200000
#
#  ADS_UF_DONT_REQUIRE_PREAUTH = 0x400000
#
#  Password expired &H800000 
#  ADS_UF_PASSWORD_EXPIRED = 0x800000
#
#  ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION = 0x1000000

    [CmdletBinding(
    DefaultParameterSetName = 'Secret'
    )]
    param(
        # User account Name
        $Users = $Script:valentia.users,

        # User account Password
        [parameter(
        mandatory,
        ParameterSetName = 'Secret')]
        [Security.SecureString]
        ${Type your OS User password},

        # User account Password
        [parameter(
        mandatory,
        ParameterSetName = 'Plain')]
        [String]
        $Password = "",

        # User account belonging UserGroup
        [string[]]
        $Groups = "administrators"
    )

    begin
    {
        $HostPC = [System.Environment]::MachineName
        $DirectoryComputer = New-Object System.DirectoryServices.DirectoryEntry("WinNT://" + $HostPC + ",computer")
        $ExistingUsers = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount='true'"

        if ($Password)
        {
            $SecretPassword = $Password | ConvertTo-SecureString -AsPlainText -Force
        }
        else
        {
            $SecretPassword = ${Type your OS User password}
        }
    }

    process
    {
        
        Write-Verbose "Checking type of users variables to retrieve property"
        if ($Users -is [System.Management.Automation.PSCustomObject])
        {
            Write-Verbose "Get properties for Parameter '$Users'."
            $pname = $Users | Get-Member -MemberType Properties | ForEach-Object{ $_.Name }

            Write-Verbose "Loop each Users in $Users"
            foreach ($p in $pname){
                if ($users.$p -notin $ExistingUsers.Name)
                {
                    Write-Verbose "$Users.$p not exist, start creating user."
                    # Create User
                    $newuser = $DirectoryComputer.Create("user", $Users.$p)
                    $newuser.SetPassword([System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecretPassword)))
                    $newuser.SetInfo()

                    # Password must change
                    $newuser.PasswordExpired = 0
                    $newuser.SetInfo()

                    # Get Account UserFlag to set
                    $userFlags = $newuser.Get("UserFlags")

                    Write-Verbose "Define user flag to define account"
                    # UserFlag for password (ex. infinity & No change Password)
                    #$userFlags = $userFlags -bor 0X10040
                    $userFlags = $userFlags -bor 0x10000

                    Write-Verbose "Put user flag to define account"
                    $newuser.Put("UserFlags", $userFlags)

                    Write-Verbose "Set user flag to define account"
                    #$newuser.SetInfo()

                    Write-Verbose "Assign User to UserGroup $Groups"
                    foreach ($Group in $Groups)
                    {
                        #Assign Group for this user
                        $DirectoryGroup = $DirectoryComputer.GetObject("group", $Group)
                        $DirectoryGroup.Add("WinNT://" + $HostPC + "/" + $Users.$p)
                    }
                }
                else
                {
                    Write-Verbose "UserName $($Users.$p) already exist. Nothing had changed."
                }
            }
        }
        elseif($Users -is [System.String])
        {
            Write-Verbose "Execute with only a user defined in $users"
            if ($users -notin $ExistingUsers.Name)
            {
                Write-Verbose "$Users not exist, start creating user."
                # Create User
                $newuser = $DirectoryComputer.Create("user", $Users)
                $newuser.SetPassword([System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($SecretPassword)))
                $newuser.SetInfo()

                # Get Account UserFlag to set
                $userFlags = $newuser.Get("UserFlags")

                # Password must change
                $newuser.PasswordExpired = 0
                $newuser.SetInfo()

                Write-Verbose "Define user flag to define account"
                #UserFlag for password (ex. infinity & No change Password)
                #$userFlags = $userFlags -bor 0X10040
                $userFlags = $userFlags -bor 0x10000

                Write-Verbose "Put user flag to define account"
                $newuser.Put("UserFlags", $userFlags)

                Write-Verbose "Set user flag to define account"
                $newuser.SetInfo()

                Write-Verbose "Assign User to UserGroup $Groups"
                #Assign Group for this user
                foreach ($Group in $Groups)
                {
                    $DirectoryGroup = $DirectoryComputer.GetObject("group", $Group)
                    $DirectoryGroup.Add("WinNT://" + $HostPC + "/" + $Users)
                }
            }
        }
        else
        {
            throw "Users must passed as string or custom define in valentia-config.ps1."
        }
    }

    end
    {
    }
}



# 配列で渡して第0要素は名前, 第1～以降はUserGroupsとして渡せます。
# , @("r.hogehoge","UserGroup1") なら、 r.hogehoge がユーザー名 / UserGroup1 がグループです。
# , @("r.fugafuga","UserGroup1","UserGroup2","UserGroup3") なら、 r.fugafuga がユーザー名 / UserGroup1、UserGroup2、UserGroup3 がグループです。



<#
, @(
    "r.hogehoge","UserGroup1"
) | %{

    $length = $_.length
    $UserInfo = [PSCustomObject]@{
        user = $_[0]
        groups = $_[1..$length]}
    
    New-ValentiaOSUser -Users $UserInfo.user -Groups $UserInfo.groups -Password "Password" -Verbose

}
#>

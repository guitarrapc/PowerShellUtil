function Get-File{

    [CmdletBinding(  
        SupportsShouldProcess = $false,
        ConfirmImpact = "none"
    )]
 
    param
    (
    [Parameter(
    Position = 0
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $Message,
	
	[Parameter(
    Position = 1
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $Extention

	)
	
    begin
    {
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") > $null
        $Dialog = New-Object System.Windows.Forms.OpenFileDialog
    }

    process
    {
        $Dialog.Title = “Select $Message File”
        $Dialog.InitialDirectory = "%UserProfile%”
		$Dialog.Filter = $Extention
        $result = $Dialog.ShowDialog()
    }

    end
    {
        If($result -eq “OK”) 
        {
            $inputFile = $Dialog.FileName
            return $inputFile
        }
        else 
        {
			return "Cancelled"
        }
    }
}

function Show-XAMLSystemTime{

    [CmdletBinding(  
        SupportsShouldProcess   = $false,
        ConfirmImpact       = "none",
        DefaultParameterSetName = ""
    )]

    param
    (
        [Parameter(
        HelpMessage = "Input path of ....",
        Position = 0,
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_.FullName})]
        [IO.FileInfo[]]
        $path,

        [Parameter(
        HelpMessage = "Enter tbind xaml @`...`@ to load.",
        Position = 0,
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $loadXaml,

        [Alias("PassThru")]
        [switch]
        $PassThrough
    )

    begin
    {
        try
        {
            # Add-Typeでアセンブリをロードする
            Add-Type -AssemblyName presentationframework
        }
        catch
        {
            #Alread Type added.
        }

        try
        {
            [xml]$xaml = $loadXaml
        }
        catch
        {
        }
    }

    process
    {
        $reader=(New-Object System.Xml.XmlNodeReader $xaml)
        $window=[Windows.Markup.XamlReader]::Load( $reader )
 
        $bOpenFileDialogTera = $window.FindName("bOpenFileDialogTera")
        $textboxTera = $window.FindName("textboxTera")
        $bOpenFileDialogkeyFile = $window.FindName("bOpenFileDialogkeyFile")
        $textboxkeyFile = $window.FindName("textboxkeyFile")
        $textboxIP = $window.FindName("textboxIP")
        $buttonOK = $window.FindName("buttonOK")
 
        $jsonFile = "Connection.json"

        #Check json file exist or not
        if(Test-Path .\$jsonFile)
        {
            $jsonRead = Get-Content $jsonFile | ConvertFrom-Json
            $textboxTera.Text = $jsonRead.tera
            $textboxkeyFile.Text = $jsonRead.keyFile
            $textboxIP.Text = $jsonRead.ip
        }

        #bOpenFileDialogTera

        $buttonTera_clicked = $bOpenFileDialogTera.add_Click
        $buttonTera_clicked.Invoke({ 
		$teraResult = Get-File -Message "tterapro.exe" -Extention “exe files (*.exe)|*.exe”
		if ($teraResult -ne "Cancelled")
		{
		 	$textboxTera.Text = $TeraResult
		}
		})

		#bOpenFileDialogkeyFile
        $buttonkeyFile_clicked = $bOpenFileDialogkeyFile.add_Click
        $buttonkeyFile_clicked.Invoke({ 
		$keyFileResult = Get-File -Message ".pem" -Extention “Pem files (*.pem)|*.pem”
		if ($keyFileResult -ne "Cancelled")
		{
		 	$textboxkeyFile.Text = $keyFileResult
		}
		})

        #buttonOK event to close window
        $buttonOK_clicked = $buttonOK.add_Click
        $buttonOK_clicked.Invoke({ 
        $Window.close()})
    }

    end
    {
        $window.ShowDialog() > $null

        #return to Powershell
        $result = [PSCustomObject]@{
            tera=$textboxTera.Text
			keyFile=$textboxkeyFile.Text
            ip=$textboxIP.Text.Trim()
        }

        $result | ConvertTo-Json -Compress | Out-File .\connection.json
        return $result
    }
}


$loadXaml =@'
        <Window 
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            Title="Invoke AWS Teraterm Connection" 
            FontFamily="consolas"
            Height="400" Width="400" Margin="5"
        >
            <StackPanel>
                <Label 
                    Name="labeltera" 
                    Content="TeraTerm execution file" 
                    Height="30" Margin="2"
					HorizontalAlignment="Center"
                />
                <Button 
                    Name="bOpenFileDialogTera" 
                    Content="Open tterapro.exe"
                    Height="30" Margin="5"
					HorizontalAlignment="Left" VerticalAlignment="Top" 
                />
                <TextBox 
                    Name="textboxTera" 
                    Text="C:\Program Files (x86)\teraterm\ttermpro.exe" 
                    Background="#00AA88"
                    Height="25" Margin="5"
                />
                <Label 
                    Name="labelkeyFile" 
                    Content="Pem Key :" 
                    Height="30" Margin="2"
					HorizontalAlignment="Center"
                />
                <Button 
                    Name="bOpenFileDialogkeyFile" 
                    Content="Open Pem File"
                    Height="30" Margin="5"
					HorizontalAlignment="Left" VerticalAlignment="Top" 
                />
                <TextBox 
                    Name="textboxkeyFile" 
                    Text="C:\Program Files (x86)\teraterm\RSA\rsa.pem" 
                    Background="#00AA88"
                    Height="25" Margin="5"
                />
                <Label 
                    Name="labelip" 
                    Content="Input AWS Server IP or Host Name" 
                    Height="30" Margin="2"
					HorizontalAlignment="Center"
                />
                <TextBox 
                    Name="textboxIP" 
                    Text="" 
                    Background="#FFFFFF"
                    Height="25" Margin="10"
                />
                <Button
                    Name="buttonOK" 
                    Content="OK" 
                    FontSize="14"
                    Foreground="#FFFFFF"
                    Background="#505050"
                    Height="40" 
                    Margin="5"
                />
            </StackPanel>
        </Window>
'@


function Enter-Teraterm{
 
    [CmdletBinding(  
        SupportsShouldProcess = $false,
        ConfirmImpact = "none"
    )]
 
    param
    (
    [Parameter(
    HelpMessage = "Input path of Terterm Pro execution file 'ttermpro.exe' exists",
    Position = 0
    )]
    [ValidateScript({Test-Path $_})]
    [ValidateNotNullOrEmpty()]
    [string]
    $teraterm="C:\Program Files (x86)\teraterm\ttermpro.exe",

    [Parameter(
    HelpMessage = "Input Connecting Hot IP/NetBIOS to connect",
    Position = 1
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $ip,

    [Parameter(
    HelpMessage = "Input Port number to connect",
    Position = 2
    )]
    [ValidateNotNullOrEmpty()]
    [int]
    $port="22",

	[Parameter(
    HelpMessage = "Input SSH type : default value = /ssh2",
    Position = 3
    )]
    [ValidateSet("/ssh1","/ssh2")] 
    [ValidateNotNullOrEmpty()]
    [string]
    $ssh="/ssh2",

    [Parameter(
    HelpMessage = "Input Authentication type : default value = publickey",
    Position = 4
    )]
    [ValidateSet("password","publickey","challenge","pageant")] 
    [ValidateNotNullOrEmpty()]
    [string]
    $auth="publickey",

    [Parameter(
    HelpMessage = "Input username to login : default value = ec2-user",
    Position = 5
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $user="ec2-user",

    [Parameter(
    HelpMessage = "Input rsa key path : default value = C:\Program Files (x86)\teraterm\RSA\rsa.pem",
    Position = 6
    )]
    [ValidateScript({Test-Path $_})]
    [ValidateNotNullOrEmpty()]
    [string]
    $keyFile="C:\Program Files (x86)\teraterm\RSA\rsa.pem"
 
    )

    begin
    {
		try
		{
			$process = New-Object System.Diagnostics.Process
		}
		catch
		{
		}
		
		try
		{
			$process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo @($teraterm)
		}
		catch
		{
		}
    }

    process
    {
		try
		{
			[string]$connection = $ip + ":" + $port
		}
		catch
		{
		}
		
		$process.StartInfo.WorkingDirectory = (Get-Location).Path

		#"C:\Program Files (x86)\teraterm\ttermpro.exe" 192.168.0.100:22 /ssh2 /auth=publickey /user=user /keyfile=D:\key.rsa
		$process.StartInfo.Arguments = "$connection $ssh /auth=$auth /user=$user `"/keyfile=$keyFile`""
		$process.Start() > $null
    }
 
}

# Open XAML View and get paramters
$WPFresult = Show-XAMLSystemTime -loadXaml $loadXaml

# Connection (Keyfile not allowed contain space)
Enter-Teraterm -teraterm $WPFresult.tera -ip $WPFresult.IP -keyFile $WPFresult.keyFile
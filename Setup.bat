@echo off & title Ensure PowerShell v2 + .Net 4

REM Author  : Leo Gillet - Freenitial on GitHub
REM Version : 1.0

setlocal EnableDelayedExpansion
set "arch=x32"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "arch=x64"
if defined PROCESSOR_ARCHITEW6432      set "arch=x64"
if exist %windir%\system32\WindowsPowerShell\v1.0\powershell.exe set "powershell=%windir%\system32\WindowsPowerShell\v1.0\powershell.exe"
if exist %windir%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe set "powershell=%windir%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
if exist %windir%\Sysnative\reg.exe (set "regNoRedirection=%windir%\Sysnative\reg.exe") else (set "regNoRedirection=%windir%\system32\reg.exe")
net session >nul 2>&1 && (set "runas=") || (set "runas=-Verb RunAs")
for /f "tokens=3*" %%A in ('%regNoRedirection% query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "osname=%%A %%B"
echo %osname% | findstr /i /c:"Windows XP"  >nul && set "runas="
echo %osname% | findstr /i /c:" 2003"       >nul && set "runas="
if defined runas (
    if defined powershell (%powershell% -NoLogo -NoProfile -Ex Bypass -Command "SAPS '%~f0' %runas% -Wait" & exit /b) ^
    else                  (echo Please restart as admin. & goto :error)
)

cd /d "%~dp0"
cd Sources
echo Current Directory : %~dp0


if "%arch%"=="x32" (
    set "PowerShellDir=%windir%\system32\WindowsPowerShell\v1.0" & set "suffix="
    set "cmdpath=%windir%\system32\cmd.exe"
    set "reg32=%windir%\system32\reg.exe"
    set "programfilesdir=%SystemDrive%\Program Files"
    set "system32=%windir%\system32"
    if not exist "%windir%\system32\mode.com"   (xcopy "mode.com" "%windir%\system32\" /i /y >nul)
    if not exist "%windir%\system32\tskill.exe" (xcopy "tskill.exe" "%windir%\system32\" /i /y >nul)
) else (
    set "PowerShellDir=%windir%\SysWOW64\WindowsPowerShell\v1.0" & set "suffix= (x86)"
    set "cmdpath=%windir%\SysWOW64\cmd.exe"
    set "reg32=%windir%\SysWOW64\reg.exe"
    set "programfilesdir=%SystemDrive%\Program Files (x86)"
    set "system32=%SystemDrive%\Windows\SysWOW64"
    if not exist "%windir%\SysWOW64\mode.com"   (xcopy "mode.com" "%windir%\SysWOW64\" /i /y >nul)
    if not exist "%windir%\SysWOW64\tskill.exe" (xcopy "tskill.exe" "%windir%\SysWOW64\" /i /y >nul)
)

%system32%\tskill.exe powershell /a 2>nul
%system32%\tskill.exe powershell_ISE /a 2>nul


:: -----------------------------------------------------------------
:: 1.  Detect OS
:: -----------------------------------------------------------------

for /f "tokens=3*" %%A in ('
  %regNoRedirection% query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul
') do set "osname=%%A %%B"

set "os_name="
echo !osname! | findstr /i /c:"Windows XP"  >nul && set "os_name=XP"
echo !osname! | findstr /i /c:" 2003"       >nul && set "os_name=2003"
echo !osname! | findstr /i /c:"Vista"       >nul && set "os_name=Vista2008"
echo !osname! | findstr /i /c:" 2008"       >nul && set "os_name=Vista2008"
echo !osname! | findstr /i /c:" 6.1 "       >nul && set "os_name=7"
echo !osname! | findstr /i /c:"Windows 7"   >nul && set "os_name=7"
echo !osname! | findstr /i /c:" 2012"       >nul && set "os_name=2012"
echo !osname! | findstr /i /c:"Windows 8"   >nul && set "os_name=8"
echo !osname! | findstr /i /c:"Windows 8.1" >nul && set "os_name=8.1"
echo !osname! | findstr /i /c:" 2016"       >nul && set "os_name=2016"
echo !osname! | findstr /i /c:"Windows 10"  >nul && set "os_name=10"
echo !osname! | findstr /i /c:" 2019"       >nul && set "os_name=2019"
echo !osname! | findstr /i /c:"Windows 11"  >nul && set "os_name=11"
echo !osname! | findstr /i /c:" 2022"       >nul && set "os_name=2022"
echo !osname! | findstr /i /c:" 2025"       >nul && set "os_name=2025"
if "!os_name!"=="" set "os_name=%osname%"

%regNoRedirection% query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CSDVersion >nul 2>&1 || (set "SP=0" & goto :skipSP)
for /f "tokens=3*" %%A in ('%regNoRedirection% query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v CSDVersion 2^>nul') do set "SP=%%A %%B"
:skipSP

echo.
echo Detected OS   : !osname! - !arch!
if defined SP echo Service Pack  : !SP!
echo.

if "!os_name!"=="XP" (
    if      "!arch!"=="x32" if "!SP:~-1!" LSS "2" (echo Windows XP x32 must be at least SP2 - aborting. & goto :error) ^
    else if "!arch!"=="x64" if "!SP:~-1!" LSS "1" (echo Windows XP x64 must be at least SP1 - aborting. & goto :error)
)


:: -----------------------------------------------------------------
:: 2.  Windows Installer 3.1
:: -----------------------------------------------------------------
if /i "!os_name!"=="XP"   if "!SP:~-1!" LSS 2 if "!arch!"=="x32" (set "windowsinstaller=true")
if /i "!os_name!"=="2003" if "!SP:~-1!" LSS 1                    (set "windowsinstaller=true")
if not defined windowsinstaller goto :skipwindowsinstaller
set "verfile=%temp%\vermsi.vbs"
> "%verfile%" echo Set f=CreateObject("Scripting.FileSystemObject") : WScript.Echo f.GetFileVersion("%system32%\msi.dll")
for /f "delims=" %%v in ('cscript /nologo "%verfile%"') do set "msiver=%%v"
del "%verfile%"
for /f "tokens=1,2 delims=." %%a in ("%msiver%") do (set "maj=%%a" & set "min=%%b")
set "old=0"
if %maj% LSS 3 set old=1
if %maj%==3 if %min% LSS 1 set old=1
if %old%==1 (
    echo Updating Windows Installer to 3.1...
    start "WindowsInstaller3.1-kb893803v2" /wait "[XP-2003]-WindowsInstaller3.1-kb893803v2.exe" /passive /norestart
) else (
    echo Windows Installer 3.1+ found
)
:skipwindowsinstaller


:: -----------------------------------------------------------------
:: 3.  Windows Imaging Component
:: -----------------------------------------------------------------
if /i "!os_name!"=="XP"   if "!SP:~-1!" == "1" set "needWIC=true"
if /i "!os_name!"=="XP"   if "!SP:~-1!" == "2" set "needWIC=true"
if /i "!os_name!"=="2003"                      set "needWIC=true"
if defined needWIC if not exist %system32%\WindowsCodecs.dll (
    echo Installing Windows Imaging Component...
    for %%F in ("WIC_XP\*_!arch!.exe") do (
        start "%%F" /wait "%%F" /passive /norestart
        set "ExitCode=!errorlevel!"
        echo %%~nxF - Exit code: !ExitCode!
        if not "!ExitCode!"=="1603" (
            echo Success - or at least not 1603. Stopping the loop.
            GOTO :endWIC
        ) else (
            echo Trying next language...
        )
    )
    echo All installers failed.
    echo Powershell installation may fail. Press any key to ignore and continue...
    pause >nul
)
:endWIC


:: -----------------------------------------------------------------
:: 4.  PowerShell 2.0
:: -----------------------------------------------------------------
set "ps=%PowerShellDir%\powershell.exe"
set "ps_ok=2"
if not exist %PowerShellDir%\powershell.exe goto :installps
%PowerShellDir%\powershell.exe -nologo -noprofile -ex bypass -command "exit [int]($Host.Version.Major -lt 2)"
set "ps_ok=%errorlevel%"
if "!ps_ok!"=="0" (echo PowerShell 2.0 or higher found & goto :endPowerShell)

:installps
set "Partial_Name_Of_Program_To_Uninstall=PowerShell"
CALL :ScanKey "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
CALL :ScanKey "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
ping -n 2 127.0.0.1 >nul

echo Checking previous PowerShell to uninstall...
%windir%\$NtUninstallKB926139$\spuninst\spuninst.exe /passive /norestart 2>nul
%windir%\$NtUninstallKB926139$\spuninst\spuninst.exe /passive /norestart 2>nul
%windir%\$968930Uinstall_KB968930$\spuninst\spuninst.exe /passive /norestart 2>nul

echo Installing PowerShell 2.0...
if /i "!os_name!"=="XP" (
    start "NetFx20SP1" /wait     "[XP-2003]-NetFx20SP1_!arch!.exe" /passive /norestart
    if "!arch!"=="x64"           (CALL :UnofficialWay) ^
    else if "!SP:~-1!"=="2"      (CALL :UnofficialWay) ^
    else (CALL :tryAllLanguages  "kb968930_XP_SP3_Official" "/passive /norestart")
) else if /i "!os_name!"=="2003" (
    start "NetFx20SP1" /wait     "[XP-2003]-NetFx20SP1_!arch!.exe" /passive /norestart
    if "!SP:~-1!" LEQ "1"        (CALL :UnofficialWay) ^
    else (CALL :tryAllLanguages  "kb968930_2003_SP2_Official" "/passive /norestart")
) else if /i "!os_name!"=="Vista2008" (
    if "!SP:~-1!" LEQ "1"         (CALL :UnofficialWay) ^
    else (start "Vista2k8" /wait "[Vista-2008]-!arch!.msu" /quiet /norestart)
)
echo End of PowerShell setup.
goto :endPowerShell

:tryAllLanguages
set "folder=%~1"
set "args=%~2"
for %%F in ("!folder!\*_!arch!.exe") do (
    start "%%F" /wait "%%F" !args!
    set "ExitCode=!errorlevel!"
    echo %%~nxF - Exit code: !ExitCode!
    if not "!ExitCode!"=="1603" (
        echo Success - or at least not 1603. Stopping the loop.
        GOTO :EOF
    ) else (
        echo Trying next language...
    )
)
echo All installers failed.
echo Press any key to ignore and continue...
pause >nul
GOTO :EOF

:ScanKey
SET "REGKEY=%~1"
echo Scanning: %REGKEY%
FOR /F "tokens=* delims=" %%K IN ('%regNoRedirection% QUERY "%REGKEY%" 2^>nul ^| findstr /R /C:"^HKEY_"') DO (
    FOR /F "tokens=2,*" %%A IN ('%regNoRedirection% QUERY "%%K" /v "DisplayName" 2^>NUL ^| findstr /I "DisplayName"') DO (
        SET "DN=%%B"
        ECHO !DN! | findstr /I "%Partial_Name_Of_Program_To_Uninstall%" >NUL
        IF NOT ERRORLEVEL 1 (
            echo.
            echo ******************************************************************
            echo   Found : !DN!
            echo ******************************************************************
            FOR /F "tokens=2,*" %%U IN ('%regNoRedirection% QUERY "%%K" /v "UninstallString" 2^>NUL ^| findstr /I "UninstallString"') DO (
                SET "CMD=%%V"
                SET "isMSI="
                echo !CMD! | findstr /I "MsiExec.exe" >NUL && (set "CMD=!CMD:/I=/X!" & set "isMSI=true")
                echo Invoking: !CMD!
                if defined isMSI (set "arguments=/qb REBOOTPROMPT=S") else (set "arguments=/passive /norestart")
                start "Uninstall_KB" /wait !CMD! !arguments!
            )
        )
    )
)
GOTO :EOF

:UnofficialWay
echo Copying PowerShell files...
xcopy kb968930_Unofficial-x32_x64\* %PowerShellDir%\ /e /q /y /i /r >nul
mkdir %PowerShellDir%\Modules >nul 2>&1
cscript.exe /nologo kb968930_Unofficial-x32_x64\_force\PowerShell.reg_6432.vbs >nul
echo Updating registry...
%reg32% import kb968930_Unofficial-x32_x64\_force\PowerShell.reg >nul
ping -n 10 127.0.0.1 >nul
echo Creating shortcuts...
%PowerShellDir%\powershell.exe -nologo -noprofile -ex bypass -file kb968930_Unofficial-x32_x64\_force\Shortcuts.ps1
GOTO :EOF

:endPowerShell


:: -----------------------------------------------------------------
:: 5.  .NET 4
:: -----------------------------------------------------------------
if /i "!os_name!"=="2003" if "!SP:~-1!"=="0" (
    echo .NET 4 is not compatible with Windows 2003 RTM, skipping.
    del %PowerShellDir%\powershell.exe.config >nul 2>&1
    goto :endDotNet
)
set "REG_KEY=HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client"
for /f "tokens=2*" %%A in ('%regNoRedirection% query "%REG_KEY%" /v Version 2^>nul') do set "NET_VER=%%B"
if not defined NET_VER goto :installDotNet
for /f "tokens=1-3 delims=." %%a in ("%NET_VER%") do (
    set "MAJ=%%a"
    set "MIN=%%b"
    set "REVSTR=%%c"
)
set /a REV=1!REVSTR! - 100000
set /a CUR_VER=MAJ*100000000 + MIN*1000000 + REV
set /a REQ_VER=4*100000000 + 0*1000000 + 30319
if !CUR_VER! geq !REQ_VER! (
    echo .NET v4+ found
    goto :endDotNet
)
:installDotNet
echo Installing .NET v4...
start "dotNetFx40_Full_x32_x64" /wait "dotNetFx40_Full_x32_x64.exe" /passive /norestart
:endDotNet


:: -----------------------------------------------------------------
:: Finish
:: -----------------------------------------------------------------
echo.
echo Install sequence completed.
ping -n 5 127.0.0.1 >nul
exit /b 3

:error
echo Press any key to exit.
pause >nul
exit /b 2
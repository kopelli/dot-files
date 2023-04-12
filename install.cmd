:<<"::SHELLSCRIPT"
@GOTO :CMDSCRIPT

::SHELLSCRIPT
echo "Run this script from 'cmd' and not from bash!"
exit $?

:CMDSCRIPT


@pushd .
:: Don't let our script variables leak beyond our script
@setlocal enableextensions enabledelayedexpansion
@SET POWERSHELL_MAJOR=7
@SET POWERSHELL_MINOR=3
@SET POWERSHELL_BUILD=3
@SET SCRIPT="%~dpnx0"
@SET SCRIPT_IS_INTERACTIVE=1
@SET POWERSHELL_VERSION=%POWERSHELL_MAJOR%.%POWERSHELL_MINOR%.%POWERSHELL_BUILD%
@SET POWERSHELL_MSI=Powershell-%POWERSHELL_VERSION%-win-x64.msi
@SET POWERSHELL_CORE_DOWNLOAD_URL=https://github.com/PowerShell/PowerShell/releases/download/v%POWERSHELL_VERSION%/%POWERSHELL_MSI%

:: Change the working directory to the directory where the script lives
@cd /d "%~dp0"

:: Search for the script's name in the command's command line,
:: if the script exists there, it liely was executed by Explorer rather than the command line
:: Inspired by https://stackoverflow.com/a/9422268
@echo %cmdcmdline% | FIND /i %SCRIPT% >nul
@IF NOT errorlevel 1 SET SCRIPT_IS_INTERACTIVE=0

:: Test if we have Powershell Core available on the system first. If we do, we should be checking that first.
@WHERE pwsh >nul
@IF /I "%ERRORLEVEL%" NEQ "0" (
  SET POWERSHELL_EXE=powershell
) ELSE (
  SET POWERSHELL_EXE=pwsh
)


@echo Checking default Powershell version
@del /F "%TEMP%\powershell_%POWERSHELL_VERSION%" >nul 2>&1
@%POWERSHELL_EXE% -Command "If ($PSVersionTable.PSVersion -lt [Version]::new("%POWERSHELL_MAJOR%","%POWERSHELL_MINOR%","%POWERSHELL_BUILD%")) { New-Item -ItemType File $env:TEMP\powershell_"%POWERSHELL_VERSION%" | Out-Null }"
@IF EXIST "%TEMP%\powershell_%POWERSHELL_VERSION%" (
  echo Downloading %POWERSHELL_CORE_DOWNLOAD_URL%
  @%POWERSHELL_EXE% -Command "Invoke-WebRequest %POWERSHELL_CORE_DOWNLOAD_URL% -OutFile $env:TEMP\%POWERSHELL_MSI%"
  del /F "%TEMP%\powershell_%POWERSHELL_VERSION%" >nul 2>&1
  @msiexec.exe /package "%TEMP%\%POWERSHELL_MSI%" /quiet ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
)

:: Check if the script is running as admin
@NET Session >nul 2>&1
@IF /I "%ERRORLEVEL%" EQU "0" (
  :: Running as admin
  SET IS_ADMIN=1
  pwsh -ExecutionPolicy RemoteSigned -Interactive -File .\install.ps1 -PSMajorVersion "%POWERSHELL_MAJOR%" -PSMinorVersion "%POWERSHELL_MINOR%" -PSBuildVersion "%POWERSHELL_BUILD%"
) ELSE (
  :: Not admin...
  SET IS_ADMIN=0
  ECHO The installer must be run as an Admin.
  EXIT /B 1
  CALL :RUNAS pwsh -ExecutionPolicy RemoteSigned -Interactive -File .\install.ps1 -PSMajorVersion "%POWERSHELL_MAJOR%" -PSMinorVersion "%POWERSHELL_MINOR%" -PSBuildVersion "%POWERSHELL_BUILD%"
)
@GOTO :Exit

:RUNAS
%POWERSHELL_EXE% -Command "Start-Process -Verb runAs %*"
EXIT /B 0

:EXIT
:: Pause only if the script was opened from Explorer
@IF "%SCRIPT_IS_INTERACTIVE%"=="0" PAUSE
@ENDLOCAL
@POPD


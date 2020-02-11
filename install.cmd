:<<"::SHELLSCRIPT"
@GOTO :CMDSCRIPT

::SHELLSCRIPT
echo "Run this script from 'cmd' and not from bash!"
exit $?

:CMDSCRIPT


@pushd .
:: Don't let our script variables leak beyond our script
@setlocal enableextensions enabledelayedexpansion
@SET POWERSHELL_MAJOR=6
@SET POWERSHELL_MINOR=2
@SET POWERSHELL_BUILD=4
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

@echo Checking default Powershell version
@del /F "%TEMP%\powershell_%POWERSHELL_VERSION%" >nul 2>&1
@powershell -Command "If ($PSVersionTable.PSVersion -lt [Version]::new("%POWERSHELL_MAJOR%","%POWERSHELL_MINOR%","%POWERSHELL_BUILD%")) { New-Item -ItemType File $env:TEMP\powershell_"%POWERSHELL_VERSION%" | Out-Null }"
@IF EXIST "%TEMP%\powershell_%POWERSHELL_VERSION%" (
  echo Downloading %POWERSHELL_CORE_DOWNLOAD_URL%
  ::@powershell -Command "Invoke-WebRequest %POWERSHELL_CORE_DOWNLOAD_URL% -OutFile $env:TEMP\%POWERSHELL_MSI%"
  del /F "%TEMP%\powershell_%POWERSHELL_VERSION%" >nul 2>&1
  ::@msiexec.exe /package "%TEMP%\%POWERSHELL_MSI%" /quiet ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
  SET DUMMY=1
)

:: Check if the script is running as admin
@NET Session >nul 2>&1
@IF /I "%ERRORLEVEL%" EQU "0" (
  :: Running as admin
  echo/
) ELSE (
  :: Not admin...
  echo/
)
@pwsh -ExecutionPolicy RemoteSigned -File .\install.ps1 -Interactive

::for /F "usebackq delims==" %%f IN (`dir /b "_*"`) DO (
::    SET _dot_file_=%%f
::    SET _dot_file_=.!_dot_file_:~1!
::REM    echo %USERPROFILE%\!_dot_file_!
::    FOR /F "usebackq delims==" %%g IN (`dir /b /s "%%f"`) DO (
::        SET _full_path_=%%g
::    )
::    del /q /f %USERPROFILE%\!_dot_file_!
::    mklink %USERPROFILE%\!_dot_file_! !_full_path_!
::)
:: --delete actual file if it exists
:: --mklink <Full path for link file> <full path of %%f>
::
:EXIT
:: Pause only if the script was opened from Explorer
@IF "%SCRIPT_IS_INTERACTIVE%"=="0" PAUSE
@ENDLOCAL
@POPD


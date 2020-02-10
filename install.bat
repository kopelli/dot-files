:<<"::SHELLSCRIPT"
@GOTO :CMDSCRIPT

::SHELLSCRIPT
echo "Run this script from 'cmd' and not from bash!"
exit $?

:CMDSCRIPT
@pushd .
:: Don't let our script variables leak beyond our script
@setlocal enableextensions enabledelayedexpansion
@SET SCRIPT="%~dpnx0"
@SET SCRIPT_IS_INTERACTIVE=1

:: Change the working directory to the directory where the script lives
@cd /d "%~dp0"

:: Search for the script's name in the command's command line,
:: if the script exists there, it liely was executed by Explorer rather than the command line
:: Inspired by https://stackoverflow.com/a/9422268
@echo %cmdcmdline% | FIND /i %SCRIPT% >nul
@IF NOT errorlevel 1 SET SCRIPT_IS_INTERACTIVE=0

:: Check if the script is running as admin
@NET Session >nul 2>&1
@IF %ERRORLEVEL% == 0 (
  :: Running as admin
  echo "Okay admin..."
) ELSE (
  :: Not admin...
  echo Sorry lowly user...
)

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

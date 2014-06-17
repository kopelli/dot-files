:<<"::SHELLSCRIPT"
@echo off
GOTO :CMDSCRIPT

::SHELLSCRIPT
echo "Run this script from 'cmd' and not from bash!"
exit $?

:CMDSCRIPT
echo Welcome to %COMSPEC%

setlocal enabledelayedexpansion

pushd .
cd %~dp0
for /F "usebackq delims==" %%f IN (`dir /b "_*"`) DO (
    SET _dot_file_=%%f
    SET _dot_file_=.!_dot_file_:~1!
    echo %USERPROFILE%\!_dot_file_!
    FOR /F "usebackq delims==" %%g IN (`dir /b /s "%%f"`) DO (
        SET _full_path_=%%g
    )
    del /q /f %USERPROFILE%\!_dot_file_!
    mklink %USERPROFILE%\!_dot_file_! !_full_path_!
)
:: --delete actual file if it exists
:: --mklink <Full path for link file> <full path of %%f>
popd
endlocal

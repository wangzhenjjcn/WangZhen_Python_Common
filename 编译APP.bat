@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "TARGET_FILE=app.py"

:: Check if app.py exists in the directory
if exist "%SCRIPT_DIR%app.py" (
    set "TARGET_FILE=app.py"
) else (
    :: Search for any file containing 'app' and end with '.py'
    set "FOUND_APP_FILE=NO"
    for /R "%SCRIPT_DIR%" %%i in (*app*.py) do (
        if not !FOUND_APP_FILE! == YES (
            set "TARGET_FILE=%%~nxi"
            set "FOUND_APP_FILE=YES"
        )
    )

    :: If no file named *app*.py found, find the first .py file larger than 1KB
    if not !FOUND_APP_FILE! == YES (
        for /R "%SCRIPT_DIR%" %%j in (*.py) do (
            if %%~zj GTR 1024 (
                set "TARGET_FILE=%%~nxj"
                goto FileFound
            )
        )
    )
)

:FileFound
echo Selected file: %TARGET_FILE%

:: Prompt for -y (Overwrite output files without asking)
set /P RESPONSE_Y="覆盖输出文件，不进行询问（默认Y）[Y/N]? "
if /I "!RESPONSE_Y!"=="N" (set "OPTION_Y=") else (set "OPTION_Y=-y")

:: Prompt for -F (Create a one-file bundled executable)
set /P RESPONSE_F="创建单文件捆绑可执行文件（默认Y）[Y/N]? "
if /I "!RESPONSE_F!"=="N" (set "OPTION_F=") else (set "OPTION_F=-F")

:: Prompt for -n (Name to assign to the bundled app, default is the filename without extension)
set "DEFAULT_NAME=%~n1"
set /P APP_NAME="为捆绑应用程序指定一个名称（默认为文件名 '%DEFAULT_NAME%'）: "
if "!APP_NAME!"=="" (set "APP_NAME=%DEFAULT_NAME%")

echo Running PyInstaller with options: %OPTION_Y% %OPTION_F% -n %APP_NAME%
python -O -m PyInstaller %OPTION_Y% %OPTION_F% -n %APP_NAME% "%SCRIPT_DIR%%TARGET_FILE%"

endlocal

@echo off
setlocal enabledelayedexpansion

:: Define the directory and default target file.
:: 定义目录和默认目标文件。
set "SCRIPT_DIR=%~dp0"
set "TARGET_FILE=app.py"

:: Check if the default Python file exists.
:: 检查默认的Python文件是否存在。
if exist "%SCRIPT_DIR%app.py" (
    echo Default app.py found.
    echo 找到默认的 app.py 文件。
) else (
    :: Search for any Python file containing 'app' in its name.
    :: 搜索名字中包含 'app' 的任何Python文件。
    set "FOUND_APP_FILE=NO"
    for /R "%SCRIPT_DIR%" %%i in (*app*.py) do (
        if not !FOUND_APP_FILE! == YES (
            set "TARGET_FILE=%%~nxi"
            set "FOUND_APP_FILE=YES"
            goto FileChecked
        )
    )

    :: If no such file found, find the first .py file larger than 1KB.
    :: 如果没有找到这样的文件，寻找第一个大于1KB的.py文件。
    if not !FOUND_APP_FILE! == YES (
        for /R "%SCRIPT_DIR%" %%j in (*.py) do (
            if %%~zj GTR 1024 (
                set "TARGET_FILE=%%~nxj"
                goto FileFound
            )
        )
    )
)

:FileChecked
:FileFound
echo Selected file: %TARGET_FILE%
:: 显示选中的文件。

:: Configure PyInstaller options.
:: 配置PyInstaller选项。
set /P RESPONSE_Y="Overwrite output files without asking (default Y) [Y/N]? 覆盖输出文件，不进行询问（默认Y）[Y/N]? "
if /I "!RESPONSE_Y!"=="N" (set "OPTION_Y=") else (set "OPTION_Y=-y")

set /P RESPONSE_F="Create a one-file bundled executable (default Y) [Y/N]? 创建单文件捆绑可执行文件（默认Y）[Y/N]? "
if /I "!RESPONSE_F!"=="N" (set "OPTION_F=") else (set "OPTION_F=-F")

set "DEFAULT_NAME=%TARGET_FILE:~0,-3%"
set /P APP_NAME="Name to assign to the bundled app, default is the filename without extension '%DEFAULT_NAME%': 为捆绑应用程序指定一个名称（默认为文件名 '%DEFAULT_NAME%'）: "
if "!APP_NAME!"=="" (set "APP_NAME=%DEFAULT_NAME%")

echo Running PyInstaller with options: %OPTION_Y% %OPTION_F% -n %APP_NAME%
:: 显示正在运行PyInstaller的选项。
python -O -m PyInstaller %OPTION_Y% %OPTION_F% -n %APP_NAME% "%SCRIPT_DIR%%TARGET_FILE%"

endlocal

@echo off
echo Building TeNRiS II with Free Pascal Compiler
echo ============================================

REM Check if Free Pascal is installed
fpc -h >nul 2>&1
if errorlevel 1 (
    echo ERROR: Free Pascal Compiler not found!
    echo Please install Free Pascal from https://www.freepascal.org/
    echo Make sure fpc.exe is in your PATH
    pause
    exit /b 1
)

REM Create output directories
if not exist "bin" mkdir bin
if not exist "lib" mkdir lib

echo Compiling TeNRiS II...

REM Compile with Free Pascal
fpc -Mdelphi -Twin32 -Scghi -O2 -g -gl -WG -Fu. -FE"bin" -FU"lib" TeNRiS.lpr

if errorlevel 1 (
    echo.
    echo ERROR: Compilation failed!
    echo Check the error messages above.
    pause
    exit /b 1
)

echo.
echo Copying required files to bin directory...

REM Copy DLL and resources to bin directory
copy "DGLEngine.dll" "bin\" >nul 2>&1
copy "*.dat" "bin\" >nul 2>&1
copy "*.ini" "bin\" >nul 2>&1
copy "*.txt" "bin\" >nul 2>&1
copy "*.ico" "bin\" >nul 2>&1

REM Copy directories
if exist "sounds" (
    if not exist "bin\sounds" mkdir "bin\sounds"
    xcopy "sounds\*" "bin\sounds\" /E /Y >nul 2>&1
)

if exist "texture" (
    if not exist "bin\texture" mkdir "bin\texture"
    xcopy "texture\*" "bin\texture\" /E /Y >nul 2>&1
)

if exist "girls" (
    if not exist "bin\girls" mkdir "bin\girls"
    xcopy "girls\*" "bin\girls\" /E /Y >nul 2>&1
)

echo.
echo SUCCESS: TeNRiS II compiled successfully!
echo Executable: bin\TeNRiS.exe
echo.
echo To run in fullscreen mode: bin\TeNRiS.exe fullscrean
echo To run in windowed mode:   bin\TeNRiS.exe
echo.

REM Ask if user wants to run the game
set /p choice="Do you want to run the game now? (y/n): "
if /i "%choice%"=="y" (
    cd bin
    TeNRiS.exe
    cd ..
)

pause

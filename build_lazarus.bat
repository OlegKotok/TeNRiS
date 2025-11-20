@echo off
echo Building TeNRiS II with Lazarus IDE
echo ===================================

REM Check if Lazarus is installed
lazbuild --help >nul 2>&1
if errorlevel 1 (
    echo ERROR: Lazarus IDE not found!
    echo Please install Lazarus from https://www.lazarus-ide.org/
    echo Make sure lazbuild.exe is in your PATH
    echo.
    echo Alternative: Use build_windows.bat for direct FPC compilation
    pause
    exit /b 1
)

echo Compiling TeNRiS II with Lazarus...

REM Build using Lazarus build tool
lazbuild --build-mode=Release TeNRiS.lpi

if errorlevel 1 (
    echo.
    echo ERROR: Compilation failed!
    echo Check the error messages above.
    pause
    exit /b 1
)

echo.
echo Copying required files...

REM Copy DLL and resources
copy "DGLEngine.dll" . >nul 2>&1
copy "*.dat" . >nul 2>&1
copy "*.ini" . >nul 2>&1

echo.
echo SUCCESS: TeNRiS II compiled successfully!
echo Executable: TeNRiS.exe
echo.

pause

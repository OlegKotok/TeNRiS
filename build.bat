@echo off
set FPC=C:\tools\freepascal\bin\i386-win32\fpc.exe

if not exist "%FPC%" (
    for /f "delims=" %%i in ('where fpc 2^>nul') do set FPC=%%i
)

if not exist "%FPC%" (
    echo FPC not found. Installing via winget...
    winget install FreePascal.FreePascal --silent
    for /r "C:\FPC" %%i in (fpc.exe) do set FPC=%%i
)

if not exist "%FPC%" (
    echo ERROR: FPC installation failed or not found.
    echo Please install manually from https://www.freepascal.org/
    pause
    exit /b 1
)

echo Using FPC: %FPC%

echo Patching source files...
powershell -Command "(Get-Content TeNRiS.dpr) -replace 'SysUtils, Windows, Messages, Graphics, ShellAPI,', 'SysUtils, Windows, Messages, SimpleGraphics,' | Set-Content TeNRiS.dpr"
powershell -Command "(Get-Content DGLEngine_header.pas) -replace 'uses Windows, Tlhelp32, Classes, SysUtils, Graphics, OpenGl;', 'uses Windows, Classes, SysUtils, SimpleGraphics, OpenGL;' | Set-Content DGLEngine_header.pas"

echo Compiling...
"%FPC%" -Mdelphi -Twin32 -O3 -WG -Fu. TeNRiS.dpr

if exist TeNRiS.exe (
    echo.
    echo Build successful! TeNRiS.exe created.
) else (
    echo.
    echo Build failed.
    pause
    exit /b 1
)

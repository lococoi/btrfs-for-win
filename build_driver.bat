@echo off
setlocal enabledelayedexpansion

REM Setup MSVC environment
call "C:\Program Files\Microsoft Visual Studio\18\Insiders\VC\Auxiliary\Build\vcvarsall.bat" amd64
if errorlevel 1 (
    echo ERROR: vcvarsall.bat failed
    exit /b 1
)

echo.
echo === Environment Check ===
echo WindowsSdkDir=%WindowsSdkDir%
echo WindowsSDKLibVersion=%WindowsSDKLibVersion%
where cl.exe
echo.

echo Checking WDK km directory...
dir "%WindowsSdkDir%Include\%WindowsSDKLibVersion%km\wdm.h" 2>nul && echo WDK Headers: OK || echo WDK Headers: NOT FOUND
dir "%WindowsSdkDir%Lib\%WindowsSDKLibVersion%km\%1\ntoskrnl.lib" 2>nul && echo WDK Libs: OK || echo WDK Libs: NOT FOUND

REM Clean and create build directory
if exist build rd /s /q build
mkdir build
cd build

REM Configure with CMake
echo.
echo === Configuring CMake ===
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release ..
if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed
    exit /b 1
)

REM Build only btrfs.sys target (the kernel driver)
echo.
echo === Building btrfs.sys ===
cmake --build . --target btrfs --config Release
if errorlevel 1 (
    echo.
    echo ERROR: Build failed
    exit /b 1
)

echo.
echo === Build Complete ===
dir *.sys 2>nul
dir *.dll 2>nul
dir *.exe 2>nul

endlocal

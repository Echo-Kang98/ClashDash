@echo off
REM Build for Windows

echo Windows ClashDash Build

cd /d "%~dp0"

echo Installing dependencies...
flutter pub get

echo Enabling Windows desktop...
flutter config --enable-windows-desktop

echo Building Windows...
flutter build windows --release

echo.
echo Build complete!
echo Output: build\windows\runner\Release\ClashDash.exe
pause

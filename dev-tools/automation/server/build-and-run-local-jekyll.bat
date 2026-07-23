@echo off

REM 프로젝트 루트로 이동
cd /d "%~dp0"
cd ..\..\..

echo ====================================
echo Building Theme Assets...
echo ====================================
call npm run build

echo.
echo ====================================
echo Cleaning Jekyll...
echo ====================================
call bundle exec jekyll clean

echo.
echo ====================================
echo Starting Jekyll Server...
echo ====================================
start "Jekyll Server" cmd /k "cd /d %CD% && bundle exec jekyll serve --livereload"

echo.
echo Waiting for server...
timeout /t 40 /nobreak >nul

echo Opening browser...
cmd /c start "" "http://localhost:4000"
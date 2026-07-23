@echo off

REM 프로젝트 루트
set PROJECT_ROOT=%~dp0..\..\..

cd /d "%PROJECT_ROOT%"

start "Jekyll Server" cmd /k "cd /d %PROJECT_ROOT% && bundle exec jekyll serve --drafts --livereload"

timeout /t 30 /nobreak >nul

start "" "http://localhost:4000"
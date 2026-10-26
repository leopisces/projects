@echo off
chcp 65001 >nul
REM ============================================================
REM  OMPCB one-click deploy (double-click to run)
REM
REM  Thin launcher for scripts\deploy.ps1 -- CMD cannot run a .ps1
REM  by double-click. Handles: cd to project root, bypass the
REM  execution policy, keep the window open when done.
REM
REM  NOTE: these comments are ASCII on purpose. CMD decodes each line
REM  using the codepage active when it reads that line, and lines are
REM  read before "chcp 65001" takes effect -- UTF-8 Chinese here gets
REM  mangled into stray commands under the GBK console default.
REM  Chinese is only used in the echo lines further below.
REM
REM  Optional args (double-click passes none):
REM    deploy.bat -SkipInstall   skip npm install, faster for code-only edits
REM    deploy.bat -Pull          git pull before building
REM ============================================================

REM %~dp0 is this file's folder (scripts\), trailing backslash included.
REM Use it rather than the current directory: on double-click the CWD
REM is not necessarily the project root.
cd /d "%~dp0.."

echo.
echo ============================================
echo   OMPCB 发布中...
echo ============================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1" %*

REM A throw inside the .ps1 sets a non-zero ERRORLEVEL. On double-click
REM the window would vanish, so surface the failure before the pause.
if errorlevel 1 (
    echo.
    echo ============================================
    echo   发布失败，请查看上方错误信息
    echo ============================================
)

echo.
pause

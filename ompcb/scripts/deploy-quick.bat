@echo off
chcp 65001 >nul
REM ============================================================
REM  OMPCB quick deploy -- same as deploy.bat but skips npm install.
REM
REM  Use this for day-to-day code changes (no package.json edits).
REM  Saves the tens of seconds npm install costs.
REM
REM  Comments are ASCII on purpose -- see the note in deploy.bat.
REM ============================================================

"%~dp0deploy.bat" -SkipInstall

@echo off
chcp 65001 >nul
cd /d "%~dp0"
set BATTLE_CITY_ROM=%~dp0..\battle_city.nes
python battle_city.py
if errorlevel 1 pause

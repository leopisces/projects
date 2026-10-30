@echo off
chcp 65001 >nul
cd /d "%~dp0"
set BATTLE_CITY_ROM=%~dp0..\battle_city.nes
start "" /b python battle_city.py --scale 1 --top --borderless
exit

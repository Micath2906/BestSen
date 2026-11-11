@echo off
chcp 65001 > nul
echo Đang khởi động Game Mèo Tự Lập...
start "" "D:\Godot\Godot_v4.3-stable_win64.exe" --path "%~dp0."
exit

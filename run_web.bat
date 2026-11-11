@echo off
chcp 65001 > nul
echo Đang khởi động Web App Mèo Tự Lập (BestSen)...
start http://localhost:3000
node server.js
pause

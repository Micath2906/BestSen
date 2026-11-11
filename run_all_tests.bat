@echo off
chcp 65001 > nul
echo ====================================================================
echo        BESTSEN - BỘ TEST RUNNER TỰ ĐỘNG HÓA TOÀN DIỆN
echo ====================================================================
echo Đang chạy toàn bộ 11 Test Suites trên Godot Engine 4.3 Headless...
echo.

set GODOT_BIN="D:\Godot\Godot_v4.3-stable_win64_console.exe"

if not exist %GODOT_BIN% (
    echo [LỖI] Không tìm thấy Godot tại %GODOT_BIN%!
    pause
    exit /b 1
)

echo [1/11] Chạy QA Complete Test Suite (Data, Scenes, Survival, Shop, Checksum)...
%GODOT_BIN% --headless tests/TestQASuite.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestQASuite thất bại!
    pause
    exit /b 1
)

echo [2/11] Chạy Test 5 Dạng Mini-Games...
%GODOT_BIN% --headless tests/TestAllMiniGames.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestAllMiniGames thất bại!
    pause
    exit /b 1
)

echo [3/11] Chạy Test Model & Animation Mèo Free Pack...
%GODOT_BIN% --headless tests/TestFreepackCat.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestFreepackCat thất bại!
    pause
    exit /b 1
)

echo [4/11] Chạy Test Tủ Đồ & Trang Trí Nhà Nhỏ...
%GODOT_BIN% --headless tests/TestHouseAndDress.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestHouseAndDress thất bại!
    pause
    exit /b 1
)

echo [5/11] Chạy Test Kỹ Năng Sống 16 Bài...
%GODOT_BIN% --headless tests/TestLifeSkillScene.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestLifeSkillScene thất bại!
    pause
    exit /b 1
)

echo [6/11] Chạy Test Mastery & Thẻ Dạy Mèo...
%GODOT_BIN% --headless tests/TestMasteryAndSequenceCards.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestMasteryAndSequenceCards thất bại!
    pause
    exit /b 1
)

echo [7/11] Chạy Test Main Menu Mới & Phòng Classic...
%GODOT_BIN% --headless tests/TestNewMainMenuAndClassicRoom.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestNewMainMenuAndClassicRoom thất bại!
    pause
    exit /b 1
)

echo [8/11] Chạy Test Hệ Thống Cửa Hàng & Phân Mục...
%GODOT_BIN% --headless tests/TestShopSystem.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestShopSystem thất bại!
    pause
    exit /b 1
)

echo [9/11] Chạy Test Hệ Thống Âm Thanh Đa Kênh...
%GODOT_BIN% --headless tests/TestSoundScene.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestSoundScene thất bại!
    pause
    exit /b 1
)

echo [10/11] Chạy Test Giới Hạn Chỉ Số & Cẩm Nang Cứu Nguy...
%GODOT_BIN% --headless tests/TestStatLimitsAndHandbook.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestStatLimitsAndHandbook thất bại!
    pause
    exit /b 1
)

echo [11/11] Chạy Test Tính Năng Mới HUD, Avatar & Dock...
%GODOT_BIN% --headless tests/TestNewFeatures.tscn
if %errorlevel% neq 0 (
    echo [FAIL] TestNewFeatures thất bại!
    pause
    exit /b 1
)

echo.
echo ====================================================================
echo  🎉 CHÚC MỪNG: TOÀN BỘ 11/11 TEST SUITES ĐÃ VƯỢT QUA 100% THÀNH CÔNG!
echo ====================================================================
echo.
pause

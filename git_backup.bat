@echo off
chcp 65001 > nul

echo ===================================================
echo   TIEN TRINH BACKUP DU AN LEN GITHUB - MUSIC APP
echo ===================================================
echo.

REM 1. Kiem tra trang thai thay doi (Git Status)
echo [1/3] Dang kiem tra trang thai file (Git Status)...
git status -s
echo.

REM 2. Nhap noi dung Commit (Neu nhan Enter se dung mac dinh)
set "commit_msg="
set /p commit_msg="Nhap noi dung commit (Nhan Enter de lay mac dinh: Auto backup): "
if "%commit_msg%"=="" (
    set commit_msg=Auto backup
)

echo.
echo [2/3] Dang chuan bi va commit cac thay doi...
git add .
git commit -m "%commit_msg%"
echo.

REM 3. Push len repository hien tai
echo [3/3] Dang push code len GitHub...
git push
echo.

echo ===================================================
echo   DA BACKUP XONG! Du an da duoc dong bo len Git.
echo ===================================================
echo.
pause

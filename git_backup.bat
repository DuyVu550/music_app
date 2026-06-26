@echo off
:: Cấu hình bảng mã UTF-8 để hiển thị tiếng Việt có dấu trong Command Prompt
chcp 65001 > nul

echo ===================================================
echo   TIẾN TRÌNH BACKUP DỰ ÁN LÊN GITHUB - MUSIC APP
echo ===================================================
echo.

:: 1. Kiểm tra trạng thái thay đổi
echo [1/3] Đang kiểm tra trạng thái file (Git Status)...
git status -s
echo.

:: 2. Nhập nội dung Commit (Nếu nhấn Enter sẽ lấy thời gian hiện tại làm mặc định)
set "commit_msg="
set /p commit_msg="Nhập nội dung commit (Nhấn Enter để dùng mặc định: Auto backup %date% %time%): "
if "%commit_msg%"=="" (
    set commit_msg=Auto backup %date% %time%
)

echo.
echo [2/3] Đang chuẩn bị và commit các thay đổi...
git add .
git commit -m "%commit_msg%"
echo.

:: 3. Push lên repository hiện tại
echo [3/3] Đang push code lên GitHub...
git push
echo.

echo ===================================================
echo   ĐÃ BACKUP XONG! Dự án đã được đồng bộ lên Git.
echo ===================================================
echo.
pause

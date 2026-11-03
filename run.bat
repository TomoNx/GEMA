@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo        GEMA - Audio Tour Guide Web Application
echo                 Docker Quick Launcher
echo ========================================================
echo.

where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker tidak terdeteksi!
    echo Silakan install dan jalankan Docker Desktop terlebih dahulu:
    echo https://www.docker.com/products/docker-desktop/
    echo.
    pause
    exit /b 1
)

if not exist .env (
    echo [INFO] Menyiapkan file .env dari .env.example...
    copy .env.example .env >nul
)

echo [INFO] Menjalankan Docker Compose (build & start)...
docker compose up -d --build

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Gagal menjalankan Docker Compose.
    pause
    exit /b 1
)

echo.
echo ========================================================
echo  GEMA BERHASIL DIJALANKAN!
echo ========================================================
echo.
echo  Aplikasi Web : http://localhost:8000
echo.
echo  Akun Guide Default:
echo    Email    : guide@gema.test
echo    Password : password
echo.
echo  Perintah Berguna:
echo    Lihat log container : docker compose logs -f
echo    Hentikan aplikasi   : docker compose down
echo.
echo ========================================================
echo Tekan sembarang tombol untuk keluar dari jendela ini...
pause >nul

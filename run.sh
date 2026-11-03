#!/usr/bin/env bash
set -e

echo "========================================================"
echo "       GEMA - Audio Tour Guide Web Application"
echo "                Docker Quick Launcher"
echo "========================================================"
echo ""

if ! command -v docker >/dev/null 2>&1; then
    echo "[ERROR] Docker tidak terdeteksi!"
    echo "Silakan install Docker terlebih dahulu:"
    echo "https://docs.docker.com/get-docker/"
    exit 1
fi

if [ ! -f .env ]; then
    echo "[INFO] Menyiapkan file .env dari .env.example..."
    cp .env.example .env
fi

echo "[INFO] Menjalankan Docker Compose (build & start)..."
docker compose up -d --build

echo ""
echo "========================================================"
echo " GEMA BERHASIL DIJALANKAN!"
echo "========================================================"
echo ""
echo " Aplikasi Web : http://localhost:8000"
echo ""
echo " Akun Guide Default:"
echo "   Email    : guide@gema.test"
echo "   Password : password"
echo ""
echo " Perintah Berguna:"
echo "   Lihat log container : docker compose logs -f"
echo "   Hentikan aplikasi   : docker compose down"
echo ""
echo "========================================================"

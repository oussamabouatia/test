@echo off
echo ============================================
echo   GeoCollege — Demarrage automatique
echo ============================================
echo.

:: 1. Demarrer Apache + MySQL via XAMPP
echo [1/2] Demarrage XAMPP (Apache + MySQL)...
start "" "C:\xampp\xampp_start.exe"
timeout /t 5 /nobreak >nul

:: 2. Demarrer ngrok avec domaine permanent
:: REMPLACE la ligne ci-dessous par TON domaine ngrok gratuit
echo [2/2] Demarrage ngrok avec domaine permanent...
echo.
echo !! IMPORTANT: Remplace YOUR-DOMAIN ci-dessous par ton vrai domaine ngrok !!
echo.
ngrok http 80 unsuited-small-clover.ngrok-free.dev

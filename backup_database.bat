@echo off
REM =====================================================
REM Backup Database Script
REM TPK Nilam - Evaluasi WS
REM =====================================================

echo ========================================
echo TPK Nilam Database Backup Script
echo ========================================
echo.

REM Set variables
set MYSQL_PATH=C:\xampp\mysql\bin
set DB_NAME=evaluasiws
set DB_USER=root
set DB_PASS=
set BACKUP_DIR=%~dp0backups
set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set BACKUP_FILE=%BACKUP_DIR%\evaluasiws_%TIMESTAMP%.sql

REM Create backup directory if not exists
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo Creating backup...
echo Database: %DB_NAME%
echo Backup to: %BACKUP_FILE%
echo.

REM Execute mysqldump
if "%DB_PASS%"=="" (
    "%MYSQL_PATH%\mysqldump.exe" -u %DB_USER% %DB_NAME% > "%BACKUP_FILE%"
) else (
    "%MYSQL_PATH%\mysqldump.exe" -u %DB_USER% -p%DB_PASS% %DB_NAME% > "%BACKUP_FILE%"
)

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Backup completed successfully!
    echo File: %BACKUP_FILE%
    echo ========================================
) else (
    echo.
    echo ========================================
    echo ERROR: Backup failed!
    echo Please check MySQL path and credentials
    echo ========================================
)

echo.
pause

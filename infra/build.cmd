@echo off
REM Batch wrapper for build.ps1
REM This allows easy execution on Windows without PowerShell execution policy issues

powershell -ExecutionPolicy Bypass -File "%~dp0build.ps1" %*

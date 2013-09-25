@echo off

pushd %~dp0
PowerShell -Command {Set-Executionpolicy RemoteSigned}
PowerShell .\Install.ps1

pause
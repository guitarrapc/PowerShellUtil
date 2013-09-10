@echo off

PowerShell -Command {Set-Executionpolicy RemoteSigned}
PowerShell .\Install.ps1

pause
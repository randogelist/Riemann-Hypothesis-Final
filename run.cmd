@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
set "RH_ROOT=%CD%"
set "RH_MODE=core"
if /i "%~1"=="full" set "RH_MODE=full"
if /i "%~1"=="search" set "RH_MODE=search"
if not "%~1"=="" if /i not "%~1"=="core" if /i not "%~1"=="full" if /i not "%~1"=="search" goto usage
if not defined RH_LEAN_EXE if defined LEAN_EXE set "RH_LEAN_EXE=%LEAN_EXE%"
if not defined RH_LEAN_EXE set "RH_LEAN_EXE=%USERPROFILE%\.elan\toolchains\leanprover--lean4---v4.33.0\bin\lean.exe"
if not exist "%RH_LEAN_EXE%" goto missing_lean
if not defined RH_MATHLIB_ROOT set "RH_MATHLIB_ROOT=-"
if not exist ".rh-cache" mkdir ".rh-cache"
if not exist ".rh-cache" goto fail
rem Atomic directory acquisition. A stale lock is never removed automatically.
2>nul mkdir ".rh-cache\writer-lock"
if errorlevel 1 goto locked
rem Never inherit unrecorded import overrides. Child imports are configured by the driver.
set "LEAN_PATH="
set "LEAN_SRC_PATH="
"%RH_LEAN_EXE%" --run "scripts\cache\Build.lean" "%RH_ROOT%" "%RH_LEAN_EXE%" "%RH_MODE%" "%RH_MATHLIB_ROOT%"
set "RH_EXIT=%ERRORLEVEL%"
rd ".rh-cache\writer-lock" >nul 2>&1
exit /b %RH_EXIT%
:usage
echo Usage: run.cmd [core^|full^|search]
echo Full mode discovers bounded prior caches; RH_MATHLIB_ROOT selects an explicit cached checkout.
exit /b 2
:missing_lean
echo GOODWORKFLOWFRONTIER::v0_1_0_construction::ERROR=LEAN_4_33_NOT_FOUND_SET_RH_LEAN_EXE
:fail
echo GOODWORKFLOWFRONTIER::v0_1_0_construction::SUMMARY=FAIL;RH_PROVED=NO
exit /b 2
:locked
echo GOODWORKFLOWFRONTIER::v0_1_0_construction::ERROR=ACTIVE_OR_STALE_WRITER_LOCK
exit /b 2

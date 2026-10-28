@echo off
setlocal EnableExtensions DisableDelayedExpansion
for %%I in ("%~dp0.") do set "RH_HILBERT_PACKAGE_ROOT=%%~fI"
if /i "%~1"=="--follow-root" goto follow_existing
if not "%~1"=="" goto usage
pushd "%RH_HILBERT_PACKAGE_ROOT%"
if errorlevel 1 exit /b 1
if not exist "%SystemRoot%\System32\cscript.exe" (
  echo RUN=FAIL
  echo REASON=Windows Script Host cscript.exe is unavailable.
  popd
  exit /b 2
)
set "RH_HILBERT_LOCK_TOKEN=%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%"
"%SystemRoot%\System32\cscript.exe" //nologo //E:JScript "%RH_HILBERT_PACKAGE_ROOT%\tools\native_runner.js" "--runner-token=%RH_HILBERT_LOCK_TOKEN%"
set "RH_HILBERT_RUN_EXIT=%errorlevel%"
popd
endlocal & exit /b %RH_HILBERT_RUN_EXIT%

:follow_existing
if "%~2"=="" goto usage
if not "%~3"=="" goto usage
if not exist "%SystemRoot%\System32\cscript.exe" (
  echo FOLLOW_STATUS=UNAVAILABLE
  echo REASON=Windows Script Host cscript.exe is unavailable.
  exit /b 2
)
"%SystemRoot%\System32\cscript.exe" //nologo //E:JScript "%RH_HILBERT_PACKAGE_ROOT%\tools\follow_active.js" "%~f2"
set "RH_HILBERT_RUN_EXIT=%errorlevel%"
endlocal & exit /b %RH_HILBERT_RUN_EXIT%

:usage
echo Usage: run.cmd [--follow-root "existing package directory"]
exit /b 64

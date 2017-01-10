@echo off

setlocal enabledelayedexpansion
setlocal enableextensions

:: root directory
set ROOT_DIR=
set OS=win

call :get_root_dir

:: server address
set SERVER_IP=192.168.14.11
set SERVER_PORT=30130

call :get_ip_address

if "%ROOT_DIR%"=="" if "%SERVER_IP%"=="" (
   set /p ROOT_DIR=install location :
   set /p SERVER_IP=host ip address :
)

if "%ROOT_DIR%"=="" if "%SERVER_IP%"=="" (
   echo invalid ROOT_DIR[%ROOT_DIR%] or SERVER_IP[%SERVER_IP%]
   echo installation failed
   exit
)

:: lua environment
set INIT=@%RD_ROOT_DIR%\src\lua_init.lua
set EXE=%RD_ROOT_DIR%bin\win\lua.exe

setx RD_ROOT_DIR  %ROOT_DIR%
setx RD_SERVER_IP %SERVER_IP%
setx HOST_OS      %OS%
setx LUA_INIT     %INIT%
setx LUA_EXE      %EXE%

set /p answer=Are your sure to install server[yes/no]:
if %answer%==yes (
   call :install_rd_server
)

echo "installation success"
exit /b

:get_root_dir
set ROOT_DIR=%~dp0
goto :eof

:get_ip_address
for /f "tokens=1,2 delims=:" %%i in ('ipconfig') do (

   set description=%%i
   set address=%%j

   for /f "delims= " %%k in ("!description!") do (
       if %%k==IPv4 (
         set SERVER_IP=!address:~1!
         goto :eof
      )
   )
)
goto :eof

:install_rd_server
schtasks /create /tn cmd_gui /tr "%LUA_EXE% %RD_ROOT_DIR%src\rd_server.lua" /sc onlogon
pause 
goto :eof

@echo on

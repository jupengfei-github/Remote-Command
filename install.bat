@echo off

setlocal enabledelayedexpansion
setlocal enableextensions

:: root directory
set ROOT_DIR=
set OS=win

call :get_root_dir

:: server address
set SERVER_IP=127.0.0.1
set SERVER_PORT=30130
set CLIENT_IP=
set CLIENT_PORT=30130

call :get_ip_address

if "%ROOT_DIR%"=="" if "%SERVER_IP%"=="" (
   set /p ROOT_DIR=install location :
   set /p SERVER_IP=machine ip address :
)

if "%ROOT_DIR%"=="" if "%SERVER_IP%"=="" (
   echo invalid ROOT_DIR[%ROOT_DIR%] or SERVER_IP[%SERVER_IP%]
   echo installation failed
   exit
)

:: lua environment
set INIT=@%ROOT_DIR%lua_init.lua
set EXE=%ROOT_DIR%bin\lua.exe

setx RD_ROOT_DIR    %ROOT_DIR%
setx RD_SERVER_IP   %SERVER_IP%
setx RD_SERVER_PORT %SERVER_PORT%
setx HOST_OS        %OS%
setx LUA_INIT       %INIT%
setx LUA_EXE        %EXE%

set /p answer=Are your sure to install server[yes/no]:
if %answer%==yes (
   call :install_rd_server
) else (
   call :install_rd_client
)

pause
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
    set /p remote_path="Enter remote share path [ex: /opt/ubuntu] : "
    set /p local_path="Enter local mount path [ex: c:] : "

    if "%remote_path%"=="" flag=1
    if "%local_path%"==""  flag=1

    if defined flag echo Invalid remote_path[%remote_path%] local_path[%local_path%] & exit 1

    call :write_server_params %remote_path% %local_path%

    ::create server VBScript
    set start_file=%ROOT_DIR%script\rd_server.vbs
    if exist %start_file% del %start_file%

    ::install schedule task
    echo '======== Auto Generated,Don't Edit ============ > %start_file%
    echo Set ws=CreateObject("Wscript.Shell") >> %start_file%
    echo ws.run "cmd /c %EXE% %ROOT_DIR%core\rd_server.lua",vbhide >> %start_file%
    schtasks /create /tn rmd /tr "%start_file%" /sc onlogon
goto :eof

:write_server_params
    set target_file_prefix=server_dirs
    set target_file=%ROOT_DIR%config\%target_file_prefix%
    set bak_file=%ROOT_DIR%config\%target_file_prefix%.bak

    for /f "delims=" %%i in (%target_file%) do (
        for /f "tokens=1,2 delims= " %%k in ("%%i") do (
            set segment1=%%k
        )

        if !segment1! neq %1 (echo %%i >> %bak_file%)
    )

    echo %1 %2>>%bak_file%
    del %target_file%
    ren %bak_file% %target_file_prefix%
goto :eof

:install_rd_client
    set /p answer=Enter remote server ip [%RD_CLIENT_IP%]:
    if %RD_CLIENT_IP%=="" if %answer%=="" (
        echo Invalid server_ip[%answer%]
        exit
    )

    setx RD_CLIENT_IP %answer%
    setx RD_CLIENT_PORT %CLIENT_PORT%

    reg add "hkcu\software\microsoft\command processor" /v Autorun /t reg_sz /d %ROOT_DIR%script/auto_run.cmd
goto :eof

@echo on

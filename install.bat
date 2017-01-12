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
    set /p remote_path="Enter remote host share path : "
    set /p local_path="Enter local host share path  : "

    if "%remote_path%"=="" flag=1
    if "%local_path%"==""  flag=1

    if defined flag echo Invalid remote_path[%remote_path%] local_path[%local_path%] & exit 1

    call :write_server_params %remote_path% %local_path%

    schtasks /create /tn cmd_gui /tr "%LUA_EXE% %RD_ROOT_DIR%src\rd_server.lua" /sc onlogon
goto :eof

:write_server_params
    set target_file=%RD_ROOT_DIR%/llib/server_cfg.lua
    set bak_file=%RD_ROOT_DIR%/llib/server_cfg.lua.bak
    set tag=share_directory_map

    set can_write=false


    for /f %%i in ('type %target_file%') do (
        for /f "delims= " %%k ("%%i") do (
            set segment=%%k
            goto end1
        )

        :end1
        if (!segment!==%tag%) (
            can_write=true 
        ) else (
            if (!can_write!==true) if (!finish_write!==false) (
                finish_write=true
                echo %map% >> %bak_file% 
            else if (!segment!==%tag_prefix%) (
                goto end
            )
        ) else if (!segment!==%tag1%) (
            can_write=false
        )

        echo %%i >> %bak_file%
        :end
    )

    del %target_file%
    ren %bak_file% %target_file%
goto :eof

@echo on

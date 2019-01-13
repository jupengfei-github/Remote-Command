@echo off

set specified_server_ip=
set specified_server_port=

setlocal enabledelayedexpansion
setlocal enableextensions

set args=
set parse_server_ip=false
set parse_server_port=false
set continue=false

for /f "delims= " %%i in ("%*") do (
    set continue=false
    set param=%%i

    if !parse_server_ip!==true  set specified_server_ip=!param!   & set continue=true
    if !parse_server_pot!==true set specified_server_port=!param! & set continue=true

    if !param:~0,2!==-h (
        set specified_server_ip=!param:~2!
        set continue=true
    )

    if !param:~0,2!==-p (
        set specified_server_port=!param:~2!
        set continue=true
    )

    if %%i==-h (
        set continue=true
        set parse_server_ip=true
    )

    if %%i==-p (
        set continue=true
        set parse_server_port=false
    )

    if !param:~0,1!==- (
        call :usage
        exit
    )

    if !conitnue!==false set args="%args% %%i"
)

:usage
    echo "Usage :"
    echo "   rd [-h host] [-p port] <command>"
    echo "                                      "
    echo "      view  [file|directory]  open file in remote host"
    echo "      custom_cmd  [args]      execute command in remote host"
goto :eof

echo %parse_server_ip% %parse_server_port%
echo %specified_server_ip% %specified_server_port%

if %parse_server_ip%=="true"   set RD_SERVER_IP=%specified_server_ip%
if %parse_server_port%=="true" set RD_SERVER_PORT=%specified_server_port%

if %LUA_EXE%!="" if %param%!="" (
    %LUA_EXE% %ROOT_DIR%/core/rd.lua %param%
)

@echo on

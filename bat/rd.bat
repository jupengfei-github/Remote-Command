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
        shift
        set specified_server_ip=!param!
    )

    if %%i==-p (
        set continue=true
        shift
        set specified_server_port=!param!
    )

    if !param:~0,1!==- (
        echo Invalid Params
        exit
    )

    if !conitnue!==false set args="%args% %%i"
)

:usage
    echo "Usage rd [-h host] [-w] <command>"
    echo "-h target host connect"
    echo "-w wait for command execute finish"
goto :eof

@echo on
echo %parse_server_ip% %parse_server_port%
echo %specified_server_ip% %specified_server_port%

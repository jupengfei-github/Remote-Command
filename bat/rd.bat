set specified_server_ip=
set specified_server_port=

setlocal enabledelayedexpansion
setlocal enableextensions

set args= 
set parse_server_ip=false
set parse_server_port=false

for %%i in (%*) do (
    if (%%i==-h) set parse_server_ip=true   & goto continue
    if (%%i==-p) set parse_server_port=true & goto continue

    if (!parse_server_ip!==true) (
        set specified_server_ip=%i
        set parse_server_ip=false
        goto continue
    )

    if (!parse_server_port!==true) (
        set specified_server_port=%i
        set parse_server_port=false
        goto continue
    )

    set args="%args% %%i"

:continue
)

if %parse_server_ip=="true"  echo Invalid Parameters & exit 1
if %parse_server_port="true" echo Invalid Parameters & exit 1

if defined specified_server_ip    setx RD_CLIENT_IP   %specified_server_ip%
if defined specified_server_port  setx RD_CLIENT_PORT %spefied_server_port%

echo $RD_CLIENT_IP $RD_CLIENT_PORT $@

if defined LUA_EXE %LUA_EXE% %RD_ROOT_DIR%/src/rd.lua %args%

set specified_server_ip=
set secified_server_port=

:usage
    echo "Usage rd [-h host] [-w] <command>"
    echo "-h target host connect"
    echo "-w wait for command execute finish"
    goto :eof

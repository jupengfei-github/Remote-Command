# root directory
export RD_ROOT_DIR=/opt/jupengfei/.cmd_gui
export HOST_OS=linux

# lua environment
export LUA_INIT=@$RD_ROOT_DIR/src/lua_init.lua

# set lua parse position
export LUA_EXE=$RD_ROOT_DIR/bin/linux/lua

# put rd command in standard path
export PATH=$PATH:$RD_ROOT_DIR/shell/rd

# alias 
source $RD_ROOT_DIR/shell/alias.sh

export RD_SERVER_IP
export RD_SERVER_PID
export RD_SERVER_PORT

export RD_CLIENT_IP
export RD_CLIENT_PORT

# server address
get_host_ip_port () {
    local ip=`ifconfig eth0|awk -F : '/inet /{print $2}'`
    RD_SERVER_IP=${ip%% *}
    RD_SERVER_PORT=30130
}

# start rd_server
start_rd_server() {
    if [ "$RD_HOST_PID" == "" ]; then
        local result=`exec $LUA_EXE $RD_ROOT_DIR/src/rd_server.lua`
        RD_SERVER_PID=`cut -f2 $result`
    fi
}

start_server=$1
if [ "$start_server" == "true" ]; then
    get_host_ip
    start_rd_server

    echo $RD_SERVER_PID
fi

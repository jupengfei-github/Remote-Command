# root directory
export RD_ROOT_DIR=/home/ubuntu/cmd_gui
export HOST_OS=linux

# lua environment
export LUA_INIT=@$RD_ROOT_DIR/src/lua_init.lua

# set lua parse position
export LUA_EXE=$RD_ROOT_DIR/bin/linux/lua

# put rd command in standard path
export PATH=$PATH:$RD_ROOT_DIR/shell/rd

# alias 
#source $RD_ROOT_DIR/shell/alias.sh

# server address
get_server_ip()  {
    local ip=`ifconfig eth0|awk -F : '/inet /{print $2}'`
    export RD_SERVER_IP=${ip%% *}
}

# start rd_server
export RD_SERVER_PID=
start_rd_server() {
    if [ "$RD_SERVER_PID" == "" ]; then
        result=`eval nohup $LUA_EXE $RD_ROOT_DIR/src/rd_server.lua 1>/dev/null 2>/dev/null &`
        RD_SERVER_PID=`cut -f2 $result`
    fi
}

start_server=$1
if [ "$start_server" == "true" ]; then
    export RD_SERVER_PORT=30130
    get_server_ip
    start_rd_server

    echo $RD_SERVER_PID
fi

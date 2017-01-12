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
<<<<<<< HEAD
source $RD_ROOT_DIR/shell/alias.sh

export RD_SERVER_IP
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
    local lua_cmd="$LUA_EXE $RD_ROOT_DIR/src/rd_server.lua"

    if ! ps -ef|grep -v grep|grep "$lua_cmd" &>/dev/null; then
        ($lua_cmd &)
    fi
}

start_server=$1
if [ "$start_server" == "true" ]; then
    get_host_ip_port
    start_rd_server
fi

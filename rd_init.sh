# root directory
export RD_ROOT_DIR=/home/ubuntu/cmd_gui
export HOST_OS=linux

# server address
export RD_SERVER_IP=192.168.14.119
export RD_SERVER_PORT=30123

# lua environment
export LUA_INIT=@$RD_ROOT_DIR/lua_init.lua

# set lua parse position
export LUA_EXE=$RD_ROOT_DIR/bin/linux/lua

# put rd command in standard path
export PATH=$PATH:$RD_ROOT_DIR

# alias 
source $RD_ROOT_DIR/shell/alias.sh

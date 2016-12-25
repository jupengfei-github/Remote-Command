#!/bin/bash

# root directory
export RD_ROOT_DIR=/home/ubuntu/cmd_gui

# server address
export RD_SERVER_IP=192.168.14.119
export RD_SERVER_PORT=62313

# lua environment
export LUA_INIT=@$RD_ROOT_DIR/init_preload.lua

# set lua parse position
LOCAL_EXECUTE_LUA="rd rd_server"

for file in `echo $LOCAL_EXECUTE_LUA`; do
    sed -i "1c#!$RD_ROOT_DIR/bin/lua" $file
done

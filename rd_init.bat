@echo off

:: root directory
set RD_ROOT_DIR=d:/cmd_gui
set HOST_OS=win

:: server address
set RD_SERVER_IP=192.168.14.171
set RD_SERVER_PORT=30130

:: lua environment
set LUA_INIT=@%RD_ROOT_DIR%/lua_init.lua
set LUA_EXE=%RD_ROOT_DIR%/bin/win/lua

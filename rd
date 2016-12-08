#!/bin/sh

if [ $LUA_EXE ]; then
    eval $LUA_EXE $RD_ROOT_DIR/src/rd.lua $@
else
    lua $RD_ROOT_DIR/src/rd.lua $@
fi

#!/bin/bash

local_path=`pwd`/$(dirname $0)
user_bashrc=$HOME/.bashrc

bashrc_cmd="source $local_path/script/rd_init"
if grep $bashrc_cmd $user_bashrc 1>/dev/null 2>/dev/null; then
    echo "Deleting init bashrc......"
    line=`grep -n "$bashrc_cmd" $user_bashrc|cut -d: -f1`
    sed -i "${line}d" $user_bashrc 
fi

echo "Uninstall Success"

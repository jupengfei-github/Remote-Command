#!/bin/bash

local_path=`pwd`
user_bashrc=$HOME/.bashrc

#set root directory
sed -i "/RD_ROOT_DIR=/c export RD_ROOT_DIR=$local_path" $local_path/shell/rd_init.sh

server=false
read -p"Are your sure to install server[yes/no] : " answers
if [ "$answers" == "yes" ]; then
    server=true
fi

bashrc_cmd="source $local_path/shell/rd_init.sh"
if ! grep "$bashrc_cmd" $user_bashrc 1>/dev/null 2>/dev/null; then
    echo                       >> $user_bashrc
    echo "#rd_init"            >> $user_bashrc
    echo "$bashrc_cmd $server" >> $user_bashrc
elif ! grep "$bashrc_cmd $server" $user_bashrc 1>/dev/null 2>/dev/null; then
    line=`grep -n "$bashrc_cmd" $user_bashrc|cut -d: -f1`

    sed -i "${line}d" $user_bashrc
    echo "$bashrc_cmd $server" >> $user_bashrc
fi

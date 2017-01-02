#!/bin/sh

local_path=`pwd`
user_bashrc=$HOME/.bashrc

bashrc_cmd="source $local_path/rd_init.sh"

if ! grep "$bashrc_cmd" $user_bashrc &> /dev/null; then
    echo >> $user_bashrc
    echo $bashrc_cmd >> $user_bashrc
fi

#set root directory
sed -i "/RD_ROOT_DIR=/c export RD_ROOT_DIR=$local_path" $local_path/rd_init.sh

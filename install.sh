#!/bin/bash

local_path=`pwd`
user_bashrc=$HOME/.bashrc

write_server_params () {
    local remote_path=$1 local_path=$2
    local target_file=$RD_ROOT_DIR/llib/server_cfg.lua

    local str=`awk -F' ' -v tag=share_directory_map '{
        if (tag == $1) {
            start_line=NR
            find_tag="true"
        }

        if (find_tag == "true" && ($1 == "}" || $1 == "},")) {
            end_line=NR
            find_tag="false"
            
            printf("%s %s", start_line, end_line)
            exit
        }
    }' $target_file`

    local start_line=${str% *}
    local end_line=${str#* }

    sed -i "$start_line,$end_line{/$remote_path/d}" $target_file

    local data="       [\"$remote_path\"] = \"$local_path\","
    sed -i "$start_line a\ $data" $target_file
}

init_server_params () {
    local remote_path local_path

    read -p"Enter remote host share path : " remote_path
    read -p"Enter local host share path  : " local_path

    if [ -z "$remote_path" -o -z "$local_path" ]; then
        echo "Invalid remote_path[$remote_path] local_path[$local_path]"
        exit 1
    fi

    write_server_params $remote_path $local_path
}

#set root directory
sed -i "/RD_ROOT_DIR=/c export RD_ROOT_DIR=$local_path" $local_path/shell/rd_init.sh

server=false
read -p"Are your sure to install server[yes/no] : " answers
if [ "$answers" == "yes" ]; then
    server=true

    init_server_params
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

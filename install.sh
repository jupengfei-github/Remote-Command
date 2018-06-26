#!/bin/bash

current_path=`pwd`
user_bashrc=$HOME/.bashrc

write_server_params () {
    local remote_path=$1 local_path1=$2
    local target_file=$current_path/src/server_cfg.lua

    local str=`awk -F' ' -v tag=share_directory_map '{
        if (tag == $2) {
            start_line=NR
            find_tag="true"
        }

        if (find_tag == "true" && ($1 == "}" || $1 == "}," || $0 == "}")) {
            end_line=NR
            printf("%s %s", start_line, end_line)
            exit
        }
    }' $target_file`

    local start_line=${str% *}
    local end_line=${str#* }

    local number=`expr $start_line + 1`
    while [ $number -lt $end_line ]; do
        sed -i "${number}d" $target_file
        end_line=`expr $end_line - 1`
    done

    data="       [\"$remote_path\"] = \"${local_path1}\","
    sed -i "$start_line a\ $data" $target_file
}

init_server_params () {
    local remote_path local_path

    read -p"Enter remote share path : " remote_path
    read -p"Enter local mount path  : " local_path

    if [ -z "$remote_path" -o -z "$local_path" ]; then
        echo "Invalid remote_path[$remote_path] local_path[$local_path]"
        exit 1
    fi

    write_server_params $remote_path $local_path
}

install_server () {
    sed -i "/ExecStart=/c ExecStart=$current_path/script/rd_server" $current_path/script/rd_server.service

    sudo cp $current_path/script/rd_server.service /etc/init.d
}

init_client_params () {
    local client_ip=$RD_SERVER_IP

    read -p"Enter remote server ip [$client_ip] : " client_ip
    client_ip=${client_ip:=$RD_SERVER_IP}

    if [ -z "$client_ip" ]; then
       echo "Invalid server_ip[$client_ip]"
       exit 1
    fi

    sed -i "/RD_SERVER_IP=/c export RD_SERVER_IP=$client_ip" $current_path/script/rd_init
}

#set root directory
sed -i "/RD_ROOT_DIR=/c export RD_ROOT_DIR=$current_path" $current_path/script/rd_init

#Delete exists record
bashrc_cmd="source $current_path/script/rd_init"
if grep "$bashrc_cmd" $user_bashrc 1>/dev/null 2>/dev/null; then
    line=`grep -n "$bashrc_cmd" $user_bashrc|cut -d: -f1`
    sed -i "${line}d" $user_bashrc
fi

#start server ifNeeded
read -p"Are your sure to install server[yes/no] : " answers
if [ "$answers" == "yes" ]; then
    init_server_params
    install_server
else
    init_client_params
    echo "$bashrc_cmd false" >> $user_bashrc
fi

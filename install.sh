#!/bin/bash

current_path=`pwd`
user_bashrc=$HOME/.bashrc
server_dir=config/server_dirs

write_server_params () {
    local remote_path=$1 local_path=$2
    local target_file=$current_path/$server_dir

    sed -i "s:$remote_path.*::;d" $target_file 2>/dev/null 1>/dev/null

    local data="$remote_path $local_path"
    echo $data >> $target_file
}

init_server_params () {
    local remote_path local_path

    read -p"Enter remote share path [ex: /opt/ubuntu] : " remote_path
    read -p"Enter local mount path  [ex: c: ] : " local_path

    if [ -z "$remote_path" -o -z "$local_path" ]; then
        echo "Invalid remote_path[$remote_path] local_path[$local_path]"
        exit 1
    fi

    write_server_params $remote_path $local_path
}

install_init_script () {
    local file=$1
    local bashrc_cmd="source $file"

    if grep "$file" $user_bashrc 1>/dev/null 2>/dev/null; then
        line=`grep -n "$file" $user_bashrc|cut -d: -f1`
        sed -i "${line}d" $user_bashrc
    fi

    echo "$bashrc_cmd" >> $user_bashrc
}

install_server () {
    sed -i "/RD_ROOT_DIR=/c export RD_ROOT_DIR=$current_path" $current_path/script/rd_server
    install_init_script $current_path/script/rd_server
}

init_client_params () {
    local client_ip=$RD_SERVER_IP

    read -p"Enter remote server ip [$client_ip] : " client_ip
    client_ip=${client_ip:=$RD_SERVER_IP}

    if [ -z "$client_ip" ]; then
       echo "Invalid server_ip[$client_ip]"
       exit 1
    fi

    sed -i "/export RD_SERVER_IP=/c export RD_SERVER_IP=$client_ip" $current_path/rd_init
    sed -i "/RD_ROOT_DIR=/c export RD_ROOT_DIR=$current_path" $current_path/rd_init
    install_init_script $current_path/rd_init

    source $user_bashrc
}

#start server ifNeeded
read -p"Are your sure to install server[yes/no] : " answers
if [ "$answers" == "yes" ]; then
    init_server_params
    install_server
else
    init_client_params
fi

unset current_path
unset user_bashrc
unset server_dir

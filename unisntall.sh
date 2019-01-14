#!/bin/bash

user_bashrc=$HOME/.bashrc

echo "Deleting init bashrc......"
sed -i "/rd_init/d"   $user_bashrc
sed -i "/rd_server/d" $user_bashrc

echo "Uninstall Success"

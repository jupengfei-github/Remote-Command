package.cpath = package.cpath .. ";/home/ubuntu/remoteDesk/test/?.so"
local socket = require("libsocket")

local server_ip   = "192.168.14.119"
local server_port = 32522
local log_tag     = "LUA_SERVER : "

socket.log("Starting test C module libsocket server")

function log (msg)
    msg = log_tag .. msg
    socket.log(msg)
end

function print_msg (msg_t) 
    local msg = ""

    for k,v in pairs(msg_t) do
        msg = msg .. v
    end

    return msg;
end

local sockfd = socket.server_socket(server_ip, server_port)
if (sockfd < 0) then
    log("create server socket failed")
    return
end

local connect_sockfd = socket.listen_connect(sockfd)
if (connect_sockfd < 0) then
    log("listen socket failed");
    return
end
log("listene connect comming")

if (socket.listen_socket(connect_sockfd) >= 0) then
    log("listen socket data comming")

    local str , len = socket.recv_data(connect_sockfd)

    if (len > 0) then
        local msg = print_msg(str);
        print("receive data : " ..  msg)
      --  socket.send_data(connect_sockfd, str)
    end
end
socket.close_socket(connect_sockfd)


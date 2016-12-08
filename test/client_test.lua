local socket = require("libsocket")
local server_ip   = "192.168.14.119"
local server_port = 32522
local log_tag     = "LUA_CLIENT : "

socket.log("Starting to test C module libsocket client")

function log (msg)
    msg  = log_tag .. msg
    socket.log(msg)
end

local sockfd = socket.client_socket(server_ip, server_port)
if (sockfd < 0) then
    log("create client socket failed")
    return
end

local send_msg = {"hello,everyone"}
socket.send_data(sockfd, send_msg)
print("end")
socket.close_socket(sockfd)

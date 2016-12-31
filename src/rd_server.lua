local Socket  = require("lsocket")
local Log     = require("log")
local PDU     = require("pdu")

local LOG_TAG = "rd_server"

local function excute_command (socket, pdu)
    local cmd = pdu:get_data()

    print(tostring(pdu))
    if (pdu:get_flag() == GLOBAL_CONSTANT_FLAG.FLAG_NONE) then
        os.execute(cmd)
    else
        local send_data = {}
        local file = io.popen(cmd, "r")

        if (file == nil) then
            send_data[1] = "excute_command "..cmd.." failed"
        else
            for line in file:lines(1024) do
                send_data[#send_data + 1] = line
            end
        end

        local send_pdu = PDU.instance()
        send_pdu:init(table.concat(send_data), GLOBAL_CONSTANT_FLAG.DATA_TYPE_TEXT, GLOBAL_CONSTANT_FLAG.MSG_TYPE_ACK, nil)

        socket:send(tostring(send_pdu))
    end
end

local function handle_client (socket)
    local recv_data = socket:recv()

    if (recv_data ~= nil) then
        local recv_pdu = PDU.parse(recv_data)

        if (recv_pdu:get_msg_type() == GLOBAL_CONSTANT_FLAG.MSG_TYPE_REQ) then
            if (recv_pdu:get_data_type() == GLOBAL_CONSTANT_FLAG.DATA_TYPE_CMD) then
                excute_command(socket, recv_pdu)
            end
        end
    else
        Log.e(LOG_TAG, "rd_server receive illegal message")
    end
end

------------------- Main Function ------------------------
local server_socket = Socket.server(config.server_ip, config.server_port)
if (server_socket == nil) then
    Log.e(LOG_TAG, "rd_server create failed")
    return 
end

repeat 
    local socket = server_socket:listen()
    if (socket ~= nil) then
        handle_client(socket)
        socket:close()
    end
until (false)

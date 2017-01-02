local Socket  = require("lsocket")
local Log     = require("log")
local PDU     = require("pdu")
local CMD_PDU = require("cmd_pdu")

local LOG_TAG = "rd_server"

local function get_local_command (cmd)
        local target_cmd = cmd

        for remote_cmd, local_cmd in pairs(config.command_map) do
            if (rmeote_cmd == cmd) then
                target_cmd = local_cmd
            break
        end
    end

    return target_cmd
end

local function excute_command (socket, pdu)
    local cmd, cmd_args = pdu:get_cmd()
    local command = get_local_command(cmd).." "..cmd_args
    local os      = os.getenv("HOST_OS")

    if (os == "win") then
        cmd_args = string.gsub(cmd_args, "/", "\\")
    elseif (os == "linux") then
        cmd_args = string.gsub(cmd_args, "\\", "/")
    end

    print(pdu, command)

    if (pdu:get_flag() == GLOBAL_CONSTANT_FLAG.FLAG_NONE) then
        os.execute(command)
    else
        local send_data = {}
        local file = io.popen(command, "r")

        if (file == nil) then
            send_data[1] = "excute_command "..cmd.." failed"
        else
            for line in file:lines(1024) do
                send_data[#send_data + 1] = line
            end
        end

        local send_pdu = PDU.instance()
        send_pdu:init(GLOBAL_CONSTANT_FLAG.DATA_TYPE_TEXT, GLOBAL_CONSTANT_FLAG.MSG_TYPE_ACK, nil)
        send_pdu:set_data(table.concat(send_data))
        socket:send(tostring(send_pdu))
    end
end

local function handle_client (socket)
    local recv_data = socket:recv()

    if (recv_data ~= nil) then
        local recv_pdu = PDU.parse(recv_data)

        if (recv_pdu:get_msg_type() == GLOBAL_CONSTANT_FLAG.MSG_TYPE_REQ) then
            if (recv_pdu:get_data_type() == GLOBAL_CONSTANT_FLAG.DATA_TYPE_CMD) then
                excute_command(socket, CMD_PDU.parse(recv_pdu))
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

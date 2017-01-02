local Socket  = require("lsocket")
local Log     = require("log")
local PDU     = require("pdu")
local CMD_PDU = require("cmd_pdu")

local LOG_TAG = "rd_server"

local function get_local_command (cmd, cmd_args, cmd_path)
    local os  = os.getenv("HOST_OS")
    local ext_command, pre_command , target_cmd = "", "", ""

    if (os == "win") then
        cmd_args = string.gsub(cmd_args, "/", "\\")
        cmd_path = string.gsub(cmd_path, "/", "\\")
        ext_command = "start /b "
    elseif (os == "linux") then
        cmd_args = string.gsub(cmd_args, "\\", "/")
        cmd_path = string.gsub(cmd_path, "\\", "/")
        ext_command = " & "
    end

    ext_command = ""

    if (cmd_path and #cmd_path > 0) then
        if (os == "win") then
            pre_command = "cd /d "..cmd_path.." & "
        else
            pre_command = "cd "..cmd_path..";"
        end
    end

    target_cmd = config.command_map[cmd]
    target_cmd = target_cmd or cmd

    local command = ""
    if (os == "win") then
        command = ext_command..pre_command..target_cmd.." "..cmd_args
    else
        command = pre_command..target_cmd.." "..cmd_args..ext_command
    end

    return command
end

local function excute_command (socket, pdu)
    local command = get_local_command(pdu:get_cmd())
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

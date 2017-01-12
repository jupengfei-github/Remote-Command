local Socket  = require("lsocket")
local Log     = require("log")
local PDU     = require("pdu")
local CMD_PDU = require("cmd_pdu")

local LOG_TAG = "rd_server"

local function get_share_file (path)
    local new_path = nil

    for remote_path, local_path in pairs(server_cfg.share_directory_map) do
        if (string.match(path, "^" .. remote_path)) then
            new_path = local_path .. string.sub(path, string.len(remote_path) + 1, -1)
            break
        end
    end

    return new_path
end

local function get_note_cus_cmd (suffix)
    local cmd = nil

    for ftype, fcmd in pairs(server_cfg.file_type_map) do
        local s, e = string.find(ftype, suffix)    

        if (s ~= nil and (s == 1 or ftype[s-1] == ":") and (e == string.len(ftype) or ftype[e+1] == ":")) then
            cmd = fcmd
            break
        end
    end

    return cmd
end

local function get_note_sys_cmd (suffix) 
    local file_type, file_cmd

    local type_file = popen("assoc ." .. suffix, "r")
    if (type_file ~= nil) then
        local msg = type_file:read("I")

        file_type = string.match(msg, "=%a+")
        type_file:close()
    end

    if (file_type ~= nil) then
        local cmd_file = popen("ftype " .. string.sub(file_type, 2), "r")
        if (cmd_file ~= nil) then
            local msg = cmd_file:read("I")

            file_cmd = string.match(msg, "=%a+")
        end
    end

    if (file_cmd ~= nil) then
        return string.sub(file_cmd, 2)
    else
        return nil
    end
end

local custom_remote_command = {
    note = function (cmd_args, cmd_path) 
        local suffix = string.match(path, "%.%a+$")
        local cmd    = get_note_cus_cmd(suffix)

        if (cmd == nil) then
            cmd = get_note_sys_cmd(suffix)
        end

        if (cmd == nil) then
            cmd = server_cfg.default
        end

        local share_file = get_share_file(path)
        if (share_file ~= nil) then
            execute_command(cmd, path)
        end
    end,
}

local function get_local_command (cmd, cmd_args, cmd_path)
    local os  = os.getenv("HOST_OS")
    local target_cmd = ""

    if (os == "win") then
        cmd_args = string.gsub(cmd_args, "/", "\\")
        cmd_path = string.gsub(cmd_path, "/", "\\")
    elseif (os == "linux") then
        cmd_args = string.gsub(cmd_args, "\\", "/")
        cmd_path = string.gsub(cmd_path, "\\", "/")
        ext_command = " & "
    end

    target_cmd = config.command_map[cmd]
    target_cmd = target_cmd or cmd
    target_cmd = target_cmd.." "..cmd_args

    if (cmd_path and #cmd_path > 0) then
        if (os == "win") then
            target_cmd = "cd /d "..cmd_path.." & start /b cmd /c "..target_cmd
        else
            target_cmd = "cd "..cmd_path..";"..target_cmd.." & "
        end
    else
        if (os == "win") then
            target_cmd = "start /b cmd /c "..target_cmd
        else
            target_cmd = target_cmd.." & "
        end
    end

    return target_cmd
end

local function handle_command (socket, pdu)
    local remote_cmd, remote_cmd_args, remote_cmd_path = pdu:get_cmd()

    for cmd, cmd_proc in pairs(server_cfg.remote_cmd_map) do
        if (remote_cmd == cmd) then
            remote_cmd = cmd_proc
            break
        end
    end

    local command = get_local_command(remote_cmd, remote_cmd_args, remote_cmd_path)

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
                handle_command(socket, CMD_PDU.parse(recv_pdu))
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

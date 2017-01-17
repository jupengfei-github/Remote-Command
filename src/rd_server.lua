local Socket  = require("lsocket")
local Log     = require("log")
local PDU     = require("pdu")
local CMD_PDU = require("cmd_pdu")

local LOG_TAG = "rd_server"

local function get_note_cus_cmd (suffix)
    local cmd = nil
    
    for ftype, fcmd in pairs(server_cfg.file_type_map) do
        local s, e = string.find(ftype, suffix)    

        if ((s == 1 or string.sub(ftype, s - 1, s - 1) == ":") and
            (e == string.len(ftype) or string.sub(ftype, e + 1, e + 1) == ":")) then
            cmd = fcmd
            break
        end
    end

    return cmd
end

local function get_note_sys_cmd (suffix) 
    local file_type, file_cmd

    local type_file = io.popen("assoc ." .. suffix, "r")
    if (type_file ~= nil) then
        local msg = type_file:read("*l")

        file_type = msg and string.match(msg, "=%a+")
        type_file:close()
    end

    if (file_type ~= nil) then
        local cmd_file = io.popen("ftype " .. string.sub(file_type, 2), "r")
        if (cmd_file ~= nil) then
            local msg = cmd_file:read("*l")

            file_cmd = msg and string.match(msg, "=%a+")
            cmd_file:close()
        end
    end

    if (file_cmd ~= nil) then
        return string.sub(file_cmd, 2)
    else
        return nil
    end
end

local custom_remote_command = {
    view = function (cmd, cmd_args, cmd_path) 
        local local_cmd = nil

        if (cmd_args ~= nil) then
            local suffix = string.match(cmd_args, "%.%a+$")

            if (suffix ~= nil) then
                suffix    = string.sub(suffix, 2)
                local_cmd = get_note_cus_cmd(suffix) or get_note_sys_cmd(suffix)
            end
        end

        if (local_cmd == nil) then
            local_cmd = server_cfg.remote_cmd_map.explore
        end
            
        return local_cmd
    end,
}

local function get_mapped_cmd (cmd, cmd_args, cmd_path) 
    local remote_cmd = cmd

    if (custom_remote_command[cmd] ~= nil) then
        remote_cmd = custom_remote_command[cmd](cmd, cmd_args, cmd_path)
    else
        for cmd, cmd_proc in pairs(server_cfg.remote_cmd_map) do
            if (remote_cmd == cmd) then
                remote_cmd = cmd_proc
                break
            end
        end
    end

    return remote_cmd
end

local function get_mapped_path (cmd_path) 
    local new_path = nil

    for remote_path, local_path in pairs(server_cfg.share_directory_map) do
        if (string.match(cmd_path, "^" .. remote_path)) then
            new_path = local_path .. string.sub(cmd_path, string.len(remote_path) + 1, -1)
            break
        end
    end

    return new_path
end

local function get_local_command (cmd, cmd_args, cmd_path)
    local os  = os.getenv("HOST_OS")
    local target_cmd = ""

    cmd_path = get_mapped_path(cmd_path)
    cmd      = get_mapped_cmd(cmd, cmd_args, cmd_path)

    if (os == "win") then
        cmd_args = string.gsub(cmd_args, "/", "\\")
        cmd_path = string.gsub(cmd_path, "/", "\\")
    elseif (os == "linux") then
        cmd_args = string.gsub(cmd_args, "\\", "/")
        cmd_path = string.gsub(cmd_path, "\\", "/")
        ext_command = " & "
    end

    target_cmd = server_cfg.remote_cmd_map[cmd]
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
    local command = get_local_command(pdu:get_cmd())

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
local server_socket = Socket.server(GLOBAL_CONFIG.server_ip, GLOBAL_CONFIG.server_port)
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

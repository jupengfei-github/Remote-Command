local Socket  = require("lsocket")
local Log     = require("log")
local PDU     = require("pdu")
local CMD_PDU = require("cmd_pdu")

local function get_note_cus_cmd (suffix)
    local cmd = nil

    for ftype, fcmd in pairs(server_cfg.file_type_map) do
        local s, e = string.find(ftype, suffix)

        if ((s == 1 or (s ~= nil and string.sub(ftype, s - 1, s - 1) == ":")) and
            (e == string.len(ftype) or (e ~= nil and string.sub(ftype, e + 1, e + 1) == ":"))) then
            cmd = fcmd
            break
        end
    end

    return cmd
end

local function get_note_sys_cmd (suffix)
    return nil
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
    local remote_cmd = nil

    if (custom_remote_command[cmd] ~= nil) then
        remote_cmd = custom_remote_command[cmd](cmd, cmd_args, cmd_path)
    end

    if remote_cmd == nil then
        remote_cmd = server_cfg.remote_cmd_map[cmd]
    end

    if remote_cmd == nil then
       remote_cmd = cmd
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
    local target_cmd = ""

    cmd_path = get_mapped_path(cmd_path)
    cmd      = get_mapped_cmd(cmd, cmd_args, cmd_path)

    cmd_args = string.gsub(cmd_args, "\\", "/")
    cmd_path = string.gsub(cmd_path, "\\", "/")
    target_cmd = cmd.." "..cmd_args

    if (cmd_path and #cmd_path > 0) then
         target_cmd = "cd "..cmd_path..";"..target_cmd.." & "
    else
        target_cmd = target_cmd.." & "
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
        Log.e("rd_server receive illegal message")
    end
end

------------------- Main Function ------------------------
local cur_path = os.getenv("RD_ROOT_DIR")
dofile(cur_path .. "/core/config.lua")

local server_socket = Socket.server(GLOBAL_CONFIG.server_ip, GLOBAL_CONFIG.server_port)
if (server_socket == nil) then
    Log.e("rd_server create failed")
    return
end

-- load server params
dofile(cur_path .. "/core/server_params.lua")

repeat
    local socket = server_socket:listen()
    if (socket ~= nil) then
        handle_client(socket)
        socket:close()
    end
until (false)

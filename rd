#!/usr/local/bin/lua

require("log")
require("socket")
require("pdu")

local function get_real_path (path)
    local cur_path = os.getenv("PWD")
    local abs_path, abs_path_stack, abs_path_stack_len

    if (string.sub(path, 1, 1) == "/") then
        abs_path = path
    else
        abs_path = cur_path.."/"..path
    end

    abs_path_stack[1]  = "/"
    abs_path_stack_len = 1
    for file_dir in string.gmatch(abs_path, "[%a%d_-]*/") do
        if (file_dir == "../") then
            abs_path_stack_len = abs_path_stack_len <= 1 and 1 or abs_path_stack_len - 1
        else
            abs_path_stack_len = abs_path_stack_len + 1
            abs_path_stack[abs_path_stack_len] = file_dir
        end
    end

    return table.concat(abs_path_stack)
end

-- open file on remote host
local function remote_desk (path)
    local real_file = get_real_path(abs_path_stack)
    local pdu = PDU.instance(true)

    pdu:set_open_file(real_file)

    local socket = Socket.client(config.server_ip)
    if (socket ~= nil) then
        socket.send(tostring(pdu))
        socket.close()
    end      
end

-- excute command on remote host
local function remote_cmd (cmd) 
    local pdu = PDU.instance(true)
    pdu:set_msg_type(GLOBAL_CONSTANT_FLAG.MSG_TYPE_REQ)
    pdu:set_data(cmd, string.len(cmd))
    pdu:set_data_type(GLOBAL_CONSTANT_FLAG.DATA_TYPE_CMD)

    local socket = Socket.client(config.server_ip)
    if (socket ~= nil) then
        socket:send(tostring(pdu))

        local recv_data = socket:recv()
        if (recv_data ~= nil) then
            local recv_pdu = PDU.parse(recv_data) 

            if (recv_pdu:get_msg_type() == GLOBAL_CONSTANT_FLAG.MSG_TYPE_ACK) then
                local d = recv_pdu:get_data()
                print(d)
            end
        end

        socket:close()
    end
end

function usage () 
return [[
    rc <remote_command> 
    rd <remote_open_file>
]]
end

-- Main Function --
if (#arg <= 0) then
    print(usage())
    return
end

local cmd = arg[0]
local path_or_cmd = table.concat(arg, " ")

if (cmd == "rd.lua") then
    remote_desk(path_or_cmd)
elseif (cmd == "rc.lua") then
    remote_cmd(path_or_cmd)
end

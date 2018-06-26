local Log     = require("log")
local Socket  = require("lsocket")
local CMD_PDU = require("cmd_pdu")
local PDU     = require("pdu")

local LOG_TAG = "rd_client"

local function get_cur_path () 
    return os.getenv("PWD")
end

-- excute command
local function execute_cmd (cmd, args, cmd_path) 
    local pdu = CMD_PDU.instance(PDU.instance(true))

    pdu:init(GLOBAL_CONSTANT_FLAG.DATA_TYPE_CMD, GLOBAL_CONSTANT_FLAG.MSG_TYPE_REQ)
    pdu:set_flag(GLOBAL_CONSTANT_FLAG.FLAG_NEED_NONE)
    pdu:set_cmd(cmd, args, cmd_path)

    local socket = Socket.client(GLOBAL_CONFIG.server_ip, GLOBAL_CONFIG.server_port)
    if (socket ~= nil) then
        socket:send(tostring(pdu))
        socket:close()
    end
end

local function default_remote_command (cmd, tb) 
    local args     = table.concat(tb, " ")
    local cur_path = get_cur_path()

    execute_cmd(cmd, args, cur_path)
end

local custom_remote_command = {
    view = function (tb) 
        local cur_path = get_cur_path()
        local file     = nil

        -- open current directory by default
        if (#tb <= 0) then
            table.insert(tb, ".")
        end

        file = table.concat(tb, " ")
        execute_cmd("view", file, cur_path)
    end,
}

-------------- Main Function ------------------
if (#arg < 1) then
    return
else
    sub_command = arg[1]
    table.remove(arg, 1)
end

for cmd, cmd_proc in pairs(custom_remote_command) do
    if (cmd == sub_command) then
        cmd_proc(arg)
        return
    end
end

default_remote_command(sub_command, arg)

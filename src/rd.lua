local Log     = require("log")
local Socket  = require("lsocket")
local CMD_PDU = require("cmd_pdu")
local PDU     = require("pdu")

local LOG_TAG = "rd_client"

local function get_real_path (path)
    local cur_path = os.getenv("PWD")
    local abs_path, abs_path_stack, abs_path_stack_len

    if (string.sub(path, 1, 1) == "/") then
        abs_path = path
    else
        abs_path = cur_path.."/"..path
    end

    abs_path_stack     = {}
    abs_path_stack_len = 0
    for file_dir in string.gmatch(abs_path, "[%a%d_-%.]*/") do
        if (file_dir == "../") then
            abs_path_stack_len = abs_path_stack_len <= 1 and 1 or abs_path_stack_len - 1
        else
            abs_path_stack_len = abs_path_stack_len + 1
            abs_path_stack[abs_path_stack_len] = file_dir
        end
    end

    local last_path = string.match(abs_path, "/[%a%d_-%.]*$")
    if (last_path ~= nil) then
        abs_path_stack[abs_path_stack_len + 1] = last_path.sub(last_path, 2, -1)
    end

    return table.concat(abs_path_stack)
end

-- excute command
local function execute_cmd (cmd, args, cmd_path) 
    local pdu = CMD_PDU.instance(PDU.instance(true))

    pdu:init(GLOBAL_CONSTANT_FLAG.DATA_TYPE_CMD, GLOBAL_CONSTANT_FLAG.MSG_TYPE_REQ)
    pdu:set_flag(GLOBAL_CONSTANT_FLAG.FLAG_NEED_NONE)
    pdu:set_cmd(cmd, args, cmd_path)

    local socket = Socket.client(config.client_ip, config.client_port)
    if (socket ~= nil) then
        socket:send(tostring(pdu))
        socket:close()
    end
end

local function help_usage () 
    print([[ Usage:
        rd <command> <args>  execute command

        <command> maybe:
            note     open file or directory 
            help     show help message
            <cmd>  <cmd> on remote host
        ]]
    )
end

local function default_remote_command (cmd, tb) 
    local args       = table.concat(tb, " ")
    local local_path = get_real_path(".")
    local share_path = get_share_path(local_path)

    execute_cmd(cmd, args, share_path)
end

local custom_remote_command = {
    note = function (tb) 
        local path = function ()
            if (#tb <= 0) then
                return "."
            else
                return table.concat(tb, " ")
            end
        end
        local real_path = get_real_path(path)

        if (real_path == nil) then
            Log.d(LOG_TAG, "invalid path : "..path)
            return
        end

        execute_cmd("note", real_path)
    end,
}

-------------- Main Function ------------------
local sub_command=arg[1]

table.remove(arg, 1)

if (sub_command == "help") then
    help_usage()
    return
else
    sub_command = "note"
end

for cmd, cmd_proc in pairs(custom_remote_command) do
    if (cmd == sub_command) then
        cmd_proc(arg)
        return
    end
end

default_remote_command(sub_command, arg)

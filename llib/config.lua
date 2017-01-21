local global_constant_flag = {
    -- message type
    MSG_TYPE_REQ = 0x00,
    MSG_TYPE_ACK = 0x01,

    -- data type
    DATA_TYPE_TEXT = 0x10,
    DATA_TYPE_CMD  = 0x11,

    -- version information
    VERSION_CODE   = "v1.0",
    VERSION_NAME   = "remoteDesk_1.0",

    -- flags
    FLAG_NEED_ACK  = 0x21,
    FLAG_NONE      = 0x20,

    -- predefined command
    CMD_NOTE       = 0x30,  -- open file with graphics
}

local global_config = {
    -- server ip
    client_ip   = "-1",
    client_port = -1, 

    -- client ip
    server_ip   = "-1",
    server_port = -1,

    valid_pdu_key = {
        "versionCode",  "versionName", "msgType",  "dataType",
        "data",         "dataPath",    "dataSize", "flag",
    },

    valid_cmd_pdu_key = {
        "cmd", "cmd_params", "cmd_path",
    },

    pre_defined_cmd = {
        CMD_NOTE,
    },
}

function generate_constant (cfg) 
    return setmetatable({}, {
        __index = function (t, k) 
            return cfg[k]
        end,

        __newindex = function (t, k)
            print("Error : write read-only table")
        end
    })
end

local function check_ip_valid (ip) 
    local pattern = "^%d+%.%d+%.%d+%.%d+$"

    if (ip == nil or not string.match(ip, pattern)) then
        return false
    end

    local valid = true
    for ele in string.gmatch(ip, "%d+") do
        local num = tonumber(ele)
        if (num <= 0 or num >= 255 ) then
            valid = false
            break
        end
    end 

    return valid
end

local function check_port_valid (port_str)
    local port = tonumber(port_str)

    if (port ~= nil and port > 0 and port < 65535) then
        return true
    else
        return false
    end
end

local ip   = os.getenv("RD_CLIENT_IP")
local port = os.getenv("RD_CLIENT_PORT")
global_config.client_ip   = check_ip_valid(ip)   and ip   or global_config.client_ip
global_config.client_port = check_port_valid(ip) and port or global_config.client_port

local ip   = os.getenv("RD_SERVER_IP")
local port = os.getenv("RD_SERVER_PORT")
global_config.server_ip   = check_ip_valid(ip)     and ip   or global_config.server_ip
global_config.server_port = check_port_valid(port) and port or global_config.server_port

GLOBAL_CONSTANT_FLAG = generate_constant(global_constant_flag)
GLOBAL_CONFIG        = generate_constant(global_config)


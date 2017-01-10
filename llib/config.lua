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
    client_ip   = 127.0.0.1,
    client_port = 30130, 

    -- client ip
    server_ip   = 127.0.0.1,
    server_port = 30130,

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
    return setmetatable(GLOBAL_CONSTANT_FLAG, {
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

local function check_port_valid (port)
    if (port ~= nil and port > 0 and port < 65535) then
        return true
    else
        return false
    end
end

GLOBAL_CONSTANT_FLAG = generate_constant(global_constant_flag)
GLOBAL_CONFIG        = generate_constant(global_config)

check_ip_valid(os.getenv("RD_CLIENT_IP"))     && config.client_ip   = ip
check_port_valid(os.getenv("RD_CLIENT_PORT")) && config.client_port = port

check_ip_valid(os.getenv("RD_SERVER_IP"))     && config.server_ip   = ip
check_port_valid(os.getenv("RD_SERVER_PORT")) && config.server_port = port

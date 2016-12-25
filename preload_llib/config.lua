global_constant_flag = {
    -- message type
    MSG_TYPE_REQ = 0x00,
    MSG_TYPE_ACK = 0x01,

    -- data type
    DATA_TYPE_TEXT = 0x10,
    DATA_TYPE_DIR  = 0x11,
    DATA_TYPE_FILE = 0x12,
    DATA_TYPE_IMAGE= 0x13,
    DATA_TYPE_DOC  = 0x14,
    DATA_TYPE_CMD  = 0x15,
    DATA_TYPE_DEF  = 0x16,

    -- version information
    VERSION_CODE   = "v1.0",
    VERSION_NAME   = "remoteDesk_1.0",
}

GLOBAL_CONSTANT_FLAG = {}
setmetatable(GLOBAL_CONSTANT_FLAG, {
    __index = function (t, k) 
        return global_constant_flag[k]
    end,

    __newindex = function (t, k)
        print("Error : write read-only table")
    end
})

config = {
    -- server ip
    server_ip   = "192.168.14.119",
    server_port = 62323, 

    -- map table
    shared_map = {
        ["/home/ubuntu"] = "z:",
    },

    file_open_map = {
        [GLOBAL_CONSTANT_FLAG.DATA_TYPE_TEXT] = "notepad++",
        [GLOBAL_CONSTANT_FLAG.DATA_TYPE_DIR]  = "explore",
        [GLOBAL_CONSTANT_FLAG.DATA_TYPE_DEF]  = "explore",
    },

    file_type_map = {
        ["jpg"] = GLOBAL_CONSTANT_FLAG.DATA_TYPE_IMAGE,
        ["png"] = GLOBAL_CONSTANT_FLAG.DATA_TYPE_IMAGE,
        ["doc"] = GLOBAL_CONSTANT_FLAG.DATA_TYPE_DOC,
        ["txt"] = GLOBAL_CONSTANT_FLAG.DATA_TYPE_TEXT,
    },

    valid_pdu_key = {
        "versionCode",
        "versionName",
        "msgType",
        "dataType",
        "data",
        "dataSize",       
    },
}

local function check_ip_valid (ip) 
    local pattern = "%d+%.%d+%.%d%.%d+"

    if (not string.match(ip, pattern)) then
        return false
    end

    local valid = true
    for ele in string.gmatch(ip, "%d+") do
        if (ele <= 0 or ele >= 255 ) then
            valid = false
            break
        end
    end
end

local function check_port_valid (port)
    if (port > 0 and port < 65535) then
        return true
    else
        return false
    end
end

local ip   = os.getenv("RD_SERVER_IP")
local port = os.getenv("RD_SERVER_PORT")

if (check_ip_valid(ip)) then
    config.server_ip = ip
end

if (check_port_valid(tonumber(port))) then
    config.server_port = port
end

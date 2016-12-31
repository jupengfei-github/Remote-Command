local global_constant_flag = {
    -- message type
    MSG_TYPE_REQ = 0x00,
    MSG_TYPE_ACK = 0x01,

    -- data type
    DATA_TYPE_TEXT = 0x10,
    DATA_TYPE_CMD  = 0x11,
    DATA_TYPE_DEF  = 0x12,

    -- version information
    VERSION_CODE   = "v1.0",
    VERSION_NAME   = "remoteDesk_1.0",

    -- flags
    FLAG_NEED_ACK  = 0x21,
    FLAG_NONE      = 0x20,

    -- file type
    FILE_TYPE_DIR  = 0x30,
    FILE_TYPE_NOR  = 0x31,
    FILE_TYPE_IMG  = 0x32,
    FILE_TYPE_WPS  = 0x33,
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
    server_ip   = "192.168.14.171",
    server_port = 30130, 

    -- map table
    shared_map = {
        ["/opt/jupengfei"] = "z:",
    },

    file_open_map = {
        [GLOBAL_CONSTANT_FLAG.FILE_TYPE_NOR] = "notepad++",
        [GLOBAL_CONSTANT_FLAG.FILE_TYPE_DIR] = "explorer",
        [GLOBAL_CONSTANT_FLAG.FILE_TYPE_WPS] = "explore",
        [GLOBAL_CONSTANT_FLAG.FILE_TYPE_IMG] = "explore",
    },

    file_type_map = {
        [GLOBAL_CONSTANT_FLAG.FILE_TYPE_NOR] = {
            "txt", "html", "xml",
        },

        [GLOBAL_CONSTANT_FLAG.FILE_TYPE_WPS] = {
            "doc", "docx", "ppt",
        },

        [GLOBAL_CONSTANT_FLAG.FILE_TYPE_IMG] = {
            "jpg", "png", "bmp",
        },
    },

    valid_pdu_key = {
        "versionCode",
        "versionName",
        "msgType",
        "dataType",
        "data",
        "dataPath",
        "dataSize",       
        "flag",
    },
}

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

local ip   = os.getenv("RD_SERVER_IP")
local port = os.getenv("RD_SERVER_PORT")

if (check_ip_valid(ip)) then
    config.server_ip = ip
end

if (check_port_valid(tonumber(port))) then
    config.server_port = port
end

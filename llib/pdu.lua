require ("log")

local LOG_TAG = "PDU"

local pduData = {}
local pduMetaTable = {}
pduMetaTable.property = {
    data        = nil,
    dataSize    = 0,
    dataType    = GLOBAL_CONSTANT_FLAG.DATA_TYPE_TEXT,
    dataPath    = nil,

    versionCode = GLOBAL_CONSTANT_FLAG.VERSION_CODE,
    versionName = GLOBAL_CONSTANT_FLAG.VERSION_NAME,

    msgType     = GLOBAL_CONSTANT_FLAG.MSG_TYPE_REQ,
    flag        = GLOBAL_CONSTANT_FLAG.FLAG_NONE,
}

-- check pdu key
local is_valid_key = function (key)
   for k,v in pairs(config.valid_keys) do
       if (v == key) then
           return true
        end
    end

    return false
end

PDU = {}

-- create new empty PDU data
-- fill : weather set default data
function PDU.instance (fill) 
    local pdu = {} 
    setmetatable(pdu, pduMetaTable)
    pduMetaTable.__index = pduMetaTable

    pdu.property = {}
    if (fill == nil or fill) then
        for k,v in pairs(pduMetaTable.property) do
            if (v ~= nill and type(v) ~= "function") then 
                pdu.property[k] = v 
            end
        end
    end

    return pdu
end

-- create PDU data from string
-- msg : serail pdu string by PDU.tostring
function PDU.parse (msg)
    local pdu = PDU.instance(false)

    for k, key in pairs(config.valid_pdu_key) do
        local si, ei = string.find(msg, " "..key.." ")

        if (si) then
            local start = string.find(msg, "%w", ei + 1)
            local endd  = string.find(msg, "\n\n", ei + 1)

            if (start and endd) then
                local tmp = string.sub(msg, start, endd - 1)

                if (string.match(tmp, "^%d+$")) then
                    pdu.property[key] = tonumber(tmp)
                else
                    pdu.property[key] = tmp
                end
            end
        end
    end

    return pdu
end

function pduMetaTable:init (data, dataType, msgType, dataPath)
    self:set_data(data)
    self:set_data_type(dataType)
    self:set_msg_type(msgType)
    self:set_data_path(dataPath)
end

function pduMetaTable:set_data (data, len)
    self.property.data     = data 
    self.property.dataSize = len or string.len(data)
end

function pduMetaTable:get_data ()
    return self.property.data, self.property.dataSize
end

function pduMetaTable:set_data_type (dType)
    self.property.dataType = dType or self.property.dataType
end

function pduMetaTable:get_data_type ()
    return self.property.dataType
end

function pduMetaTable:set_msg_type (mtype)
    self.property.msgType = mtype or self.property.msgType
end

function pduMetaTable:get_msg_type ()
    return self.property.msgType
end

function pduMetaTable:set_flag (flag)
    self.flag = flag or self.flag
end

function pduMetaTable:get_flag ()
    return self.flag
end

local generate_abs_path = function (path)
    if (type(path) ~= "string" or string.len(path) == 0) then
        return nil
    end

    local path_pattern = "^/?[a-z0-9_A-Z](/[a-z0-9_A-Z])*/?$"
    if (not string.match(path, path_pattern)) then
        Log.e(LOG_TAG, "illegal file path "..path)
        return nil
    end

    if (string.sub(path, 1, 1) == "/") then
        return path
    end

    local current_dir = os.getenv("PWD")
    return current_dir.."/"..path
end

local get_file_shared_dir = function (path) 
    local map = config.shared_map
    local pattern = ""
    local ret = nil

    for path_prefix, path_map in pairs(ma) do
        pattern = "^"..path_prefix
        local i, j = string.find(path, pattern)

        if (i) then
            ret = path_prefix..string.sub(path, j + 1, -1) 
            break
        end
    end

    return ret
end

function pduMetaTable:set_data_path (path)
    local path = generate_abs_path(path)
    local file = io.open(path, "r")

    if (file == nil) then
        Log.e(LOG_TAG, "file "..path.." not exists")
        return 
    end

    local remote_dir = get_file_shared_dir (path)
    if (remote_dir == nil) then
        Log.e(LOG_TAG, "file "..path.." isn't shared, not supported")
        return
    end

    self.dataPath = remote_dir
end

function pduMetaTable:set_data_path (path)
    self.dataPath = path
end

function pduMetaTable:get_data_path ()
    return self.dataPath
end

function pduMetaTable:get_version ()
   return self.property.versionCode, self.property.versionName
end

function pduMetaTable:__tostring ()
    local msg = ""

    for k, v in pairs(self.property) do
        if (v ~= nil) then
            msg = " "..k.." : "..v.."\n\n"..msg
        end
    end

    return msg
end

Log = require ("log")

local LOG_TAG       = "PDU"
local PDU_DELIMETER = "\t "
local PDU_KEYVALUE  = ":"

local pduData = {}
local pduMetaTable = {}
pduMetaTable.property = {
    versionCode = GLOBAL_CONSTANT_FLAG.VERSION_CODE,
    versionName = GLOBAL_CONSTANT_FLAG.VERSION_NAME,

    data        = nil,
    dataSize    = 0,
    dataType    = GLOBAL_CONSTANT_FLAG.DATA_TYPE_TEXT,

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

local PDU = {}
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
        local si, ei = string.find(msg, key..PDU_KEYVALUE)

        if (si) then
            local start = string.find(msg, "%w", ei + 1)
            local endd  = string.find(msg, PDU_DELIMETER, ei + 1)

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

function pduMetaTable:init (dataType, msgType)
    self:set_data_type(dataType)
    self:set_msg_type(msgType)
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
    self.property.flag = flag or self.property.flag
end

function pduMetaTable:get_flag ()
    return self.property.flag
end

function pduMetaTable:get_version ()
   return self.property.versionCode, self.property.versionName
end

function pduMetaTable:__tostring ()
    local msg = " "

    for k, v in pairs(self.property) do
        if (v ~= nil) then
            msg = k..PDU_KEYVALUE..v..PDU_DELIMETER..msg
        end
    end

    return msg
end

return PDU

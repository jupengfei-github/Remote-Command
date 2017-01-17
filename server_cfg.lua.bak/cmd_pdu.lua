PDU = require("pdu")

local CMD_PDU           = {}
local CMD_PDU_metatable = {}

local CMD_PDU_DELIMETER = "; "
local CMD_PDU_KEYVALUE  = "="

function CMD_PDU.instance (pdu) 
    local cmd_pdu = {}

    cmd_pdu.property = setmetatable({
        cmd        = "",
        cmd_params = "", 
        cmd_path   = "",
    }, {
        __index    = pdu.property,
        __newindex = function (tb, key, value)
            pdu.property[key] = value
        end
    })

    setmetatable(cmd_pdu, {
        __index    = CMD_PDU_metatable,
        __tostring = CMD_PDU_metatable.__tostring
    })

    setmetatable(CMD_PDU_metatable, {
        __index = pdu
    })

    cmd_pdu.parent = pdu

    return cmd_pdu
end

function CMD_PDU.parse (pdu)
    local msg     = pdu:get_data()
    local cmd_pdu = CMD_PDU.instance(pdu)

    for k, key in pairs(config.valid_cmd_pdu_key) do
        local si, ei = string.find(msg, key..CMD_PDU_KEYVALUE)

        if (si) then
            local start = string.find(msg, "[%w-_]*", ei + 1)
            local endd  = string.find(msg, CMD_PDU_DELIMETER, ei + 1)

            if (start and endd) then
                local tmp = string.sub(msg, start, endd - 1)

                if (string.match(tmp, "^%d+$")) then
                    cmd_pdu.property[key] = tonumber(tmp)
                else
                    cmd_pdu.property[key] = tmp
                end
            end
        end
    end

    return cmd_pdu
end

function CMD_PDU_metatable:get_cmd ()
    return self.property.cmd, self.property.cmd_params, self.property.cmd_path
end

function CMD_PDU_metatable:set_cmd (cmd, cmd_params, cmd_path)
    self.property.cmd        = cmd
    self.property.cmd_params = cmd_params
    self.property.cmd_path   = cmd_path

    local str = ""
    for k,v in pairs(self.property) do
        str = k..CMD_PDU_KEYVALUE..v..CMD_PDU_DELIMETER..str
    end

    self:set_data(str)
end

function CMD_PDU_metatable:__tostring ()
    return tostring(self.parent)
end

return CMD_PDU

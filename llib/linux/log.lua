local vlog = require("liblog")

local function log_detail (tag, level, msg)
    local msg = level .. " "..msg
    vlog.log (tag, msg)
end

local Log = {}
function Log.d (tag, msg)
    log_detail (tag, "DEBUG", msg)
end

function Log.i (tag, msg)
    log_detail (tag, "INFO", msg)
end

function Log.e (tag, msg)
    log_detail (tag, "ERROR", msg)
end

function Log.v (tag, msg)
    log_detail (tag, "VERBOSE", msg)
end

return Log

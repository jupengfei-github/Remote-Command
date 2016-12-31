local util = require("libutil")

local Util = {}
function Util.is_dir (path)
    if (path == nil or type(path) ~= "string") then
        return false
    end

    return util.is_dir(path)
end

return Util

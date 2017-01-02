local util = require("libutil")

local Util = {}
function Util.is_dir (path)
    if (path == nil or type(path) ~= "string") then
        return false
    end

    return util.file_type(path) == 1
end

function Util:is_file (path)
    if (path == nil or type(path) ~= "string") then
        return false
    end

    return util.file_type(path) == 2
end

return Util

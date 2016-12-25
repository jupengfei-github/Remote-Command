util = require("libutil")

Util = {}
function Util.is_dir (path)
    if (path == nil or type(path) ~= "string") then
        return false
    end

    return util.is_dir(path)
end

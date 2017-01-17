local util = require("libutil")

local Util = {}
function Util.is_dir (path)
    assert(path)
    return util.file_type(path) == 1
end

function Util.is_file (path)
    assert(path)
    return util.file_type(path) == 2
end

return Util

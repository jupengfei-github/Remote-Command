local function parse_server (path)
    local f = assert(io.open(path, "r"))
    local result = {}

    local line = f:read("*line")
    while line ~= nil do
        local temp = {}
        string.gsub(line, "[^ ]+", function (w)
            table.insert(temp, w)
        end)

        result[tmep[0]] = temp[1]
        line = f:read("*line")
    end

    return result
end

local cur_path = os.getenv("RD_ROOT_DIR")
local dirs = cur_path .. "/config/server_dirs"
local cmds = cur_path .. "/config/server_cmds"
local maps = cur_path .. "/config/server_maps"

server_cfg = {
    ["remote_cmd_map"]      = parse_server(cmds),    -- offer avalable commands
    ["share_directory_map"] = parse_server(dirs),    -- map remoteDir to LocalDir
}

local function parse_file_type (path)
    local remote_cmds = server_cfg.remote_cmd_map
    local map = parse_server(path)
    local result = {}

    for k, v in pairs(map) do
        result[k] = remote_cmds[v]
    do

    return result
end

server_cfg["file_type_map"] = parse_file_type(maps)  -- map fileType to Commands
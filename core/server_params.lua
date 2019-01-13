local function parse_server (path)
    local f = assert(io.open(path, "r"))
    local result = {}

    local line = f:read("*line")
    while line ~= nil do
	local temp = {}

        for w in string.gmatch(line, "%g+") do
	    table.insert(temp, w)
	end

	if #temp >= 2 and temp[1] ~= "#" then
            result[temp[1]] = temp[2]
	end

        line = f:read("*line")
    end

    return result
end

local cur_path = os.getenv("RD_ROOT_DIR")
local dirs = cur_path .. "/config/server_dirs"
local cmds = cur_path .. "/config/server_cmds"
local maps = cur_path .. "/config/server_maps"

server_cfg = {
    ["remote_cmd_map"]      = parse_server(cmds),  -- offer avalable commands
    ["share_directory_map"] = parse_server(dirs),  -- map remoteDir to LocalDir
}

local function parse_file_type (path)
    local remote_cmds = server_cfg.remote_cmd_map
    local map = parse_server(path)
    local result = {}

    for k, v in pairs(map) do
        result[k] = remote_cmds[v]
    end

    return result
end

server_cfg["file_type_map"] = parse_file_type(maps)  -- map fileType to Commands

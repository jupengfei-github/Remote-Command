local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")

-- set custom c search path
local built_c_path = function ()
    local lib_path = { RD_ROOT_DIR .. "/lib/?.so", }
    return lib_path
end

-- set custom lua search path
local built_lua_path = function ()
    local lib_path = {
            [1] = RD_ROOT_DIR .. "/src/?.lua",
			[2] = RD_ROOT_DIR .. "/src/?.lua",
        }

    lib_path[#lib_path + 1] = RD_ROOT_DIR .. "\\src\\?.lua"
    return lib_path
end

local USER_C_PATHS   = built_c_path()
local USER_LUA_PATHS = built_lua_path()

-- cpath
local cpath = package.cpath
for k,v in pairs(USER_C_PATHS) do
    if (not string.match(cpath, v)) then
        package.cpath = package.cpath ..";".. v
    end
end

-- lua path
local path = package.path
for k,v in pairs(USER_LUA_PATHS) do
        if (not string.match(path, v)) then
        package.path = package.path ..";".. v
    end
end

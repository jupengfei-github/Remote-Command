local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")

-- custom c search path
local USER_C_PATHS = {
    RD_ROOT_DIR.."/lib/?.so",
}

-- custom lua search path
local USER_LUA_PATHS = {
    RD_ROOT_DIR.."/llib/?.lua"
}

if (not custom_lib_loaded) then
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

    custom_lib_loaded = true
end

-- excute custom program
local config_dir = RD_ROOT_DIR.."/preload_llib/config.lua"
dofile(config_dir)

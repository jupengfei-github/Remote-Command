local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")
local host_os     = os.getenv("HOST_OS")

-- set custom c search path
local built_c_path = function ()
    local lib_path = {}

    if host_os == "linux" then
        lib_path = {
            RD_ROOT_DIR.."/lib/linux/?.so",
        }
    elseif host_os == "win" then
        lib_path = {
            RD_ROOT_DIR.."lib\\win\\?.dll",
        }
    end

    return lib_path
end

-- set custom lua search path
local built_lua_path = function ()
    local lib_path = {}

    if host_os == "linux" then
        lib_path = {
            [1] = RD_ROOT_DIR.."/llib/linux/?.lua",
        }
    elseif host_os == "win" then
        lib_path = {
            [1] = RD_ROOT_DIR.."llib\\win\\?.lua",
        }
    end

    lib_path[#lib_path + 1] = RD_ROOT_DIR.."\\llib\\?.lua"

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

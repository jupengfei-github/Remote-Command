local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")
local HOST_OS     = os.getenv("HOST_OS")

local preload_c_path   = RD_ROOT_DIR.."/external/lib"
local preload_lua_path = RD_ROOT_DIR.."/external/llib"

local preload_c_path, preload_lua_path

-- preload modules for win
local preload_c_modules_win = {
    "socket/core.dll",
}

local preload_lua_modules_linux = {
    "socket.lua",
}

-- preload modules for linux
local preload_c_modules_linux = {

}

local preload_lua_modules_linux = {

}

if HOST_OS == "win" then
    preload_c_path = preload_c_modules_win
    preload_lua_path = preload_lua_modules_win
else
    preload_c_path = preload_c_modules_linux
    preload_lua_path = preload_lua_modules_linux
end

for key, path in pairs(preload_c_path) do
    local real_path = preload_c_path.."/"..path
    package.cpath = package.cpath ..";".. real_path
end

for key, path in pairs(preload_lua_path) do
    local real_path = preload_lua_path.."/"..path
    package.path = package.path ..";".. real_path
end


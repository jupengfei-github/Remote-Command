local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")
local HOST_OS     = os.getenv("HOST_OS")

local preload_c_dir   = RD_ROOT_DIR.."/external/lib/"
local preload_lua_dir = RD_ROOT_DIR.."/external/llib/"

local preload_c_path, preload_lua_path

local preload_c_modules = {

}

local preload_lua_modules = {

}

preload_c_path   = preload_c_modules
preload_lua_path = preload_lua_modules

for key, path in pairs(preload_c_path) do
    local real_path = preload_c_dir .. path
    package.cpath = package.cpath ..";".. real_path
end

for key, path in pairs(preload_lua_path) do
    local real_path = preload_lua_dir .. path
    package.path = package.path ..";".. real_path
end


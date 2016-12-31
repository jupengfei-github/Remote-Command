local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")
local HOST_OS     = os.getenv("HOST_OS")

local preload_c_path   = RD_ROOT_DIR.."/external/lib"
local preload_lua_path = RD_ROOT_DIR.."/external/llib"

-- preload modules
local preload_c_modules = {
    "socket",
}

local preload_lua_modules = {
    "core.dll",
}

for key, path in pairs(preload_c_modules) do
    local real_path = preload_c_path.."/"..path
    package.cpath = package.cpath ..";".. real_path
end

for key, path in pairs(preload_lua_modules) do
    local real_path = preload_lua_path.."/"..path
    package.path = package.path ..";".. real_path
end


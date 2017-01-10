local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")
local HOST_OS     = os.getenv("HOST_OS")

local preload_c_dir   = RD_ROOT_DIR.."/external/lib/"
local preload_lua_dir = RD_ROOT_DIR.."/external/llib/"

local preload_c_path, preload_lua_path

-- preload modules for win
local preload_c_modules_win = {
	"?.dll",
}

local preload_lua_modules_win = {
	"?.lua",
}

-- preload modules for linux
local preload_c_modules_linux = {

}

local preload_lua_modules_linux = {

}

if HOST_OS == "win" then
    preload_c_path = preload_c_modules_win
    preload_lua_path = preload_lua_modules_win
	
	preload_c_dir    = preload_c_dir   .. "win/"
	preload_lua_dir  = preload_lua_dir .. "win/"
else
    preload_c_path   = preload_c_modules_linux
    preload_lua_path = preload_lua_modules_linux
	
	preload_c_dir    = preload_c_dir   .. "linux/"
	preload_lua_dir  = preload_lua_dir .. "linux/"
end

for key, path in pairs(preload_c_path) do
    local real_path = preload_c_dir .. path
    package.cpath = package.cpath ..";".. real_path
end

for key, path in pairs(preload_lua_path) do
    local real_path = preload_lua_dir .. path
    package.path = package.path ..";".. real_path
end


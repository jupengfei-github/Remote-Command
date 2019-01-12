local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")

local USER_C_PATHS   = {
    RD_ROOT_DIR .. "/lib/?.so",
}

local USER_LUA_PATHS = {
    RD_ROOT_DIR .. "/core/?.lua",
    RD_ROOT_DIR .. "/module/?.lua",
}

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

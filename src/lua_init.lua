local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")
local host_os     = os.getenv("HOST_OS")

dofile(RD_ROOT_DIR .. "/src/config.lua")
dofile(RD_ROOT_DIR .. "/src/server_cfg.lua")
dofile(RD_ROOT_DIR .. "/src/init_core.lua")
dofile(RD_ROOT_DIR .. "/external/init_external.lua")

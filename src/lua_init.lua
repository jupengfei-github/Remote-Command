local RD_ROOT_DIR = os.getenv("RD_ROOT_DIR")
local host_os     = os.getenv("HOST_OS")

dofile(RD_ROOT_DIR .. "/llib/config.lua")
dofile(RD_ROOT_DIR .. "/llib/server_cfg.lua")
dofile(RD_ROOT_DIR .. "/llib/init_core.lua")
dofile(RD_ROOT_DIR .. "/external/init_external.lua")

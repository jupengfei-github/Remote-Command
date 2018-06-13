-- custom remote command                          
local remote_cmd_map = {                         
    explore  = "dolphin 2>/dev/null",                       
    file     = "subl",                         
    search   = "krunner",                         
    compare  = "vimdiff",                         
}

-- command for specified file                         
local file_type_map = {                         
    ["txt:html:xml"] = remote_cmd_map.file,                         
}

-- shared directory. Don't edit this. Auto generated                         
local share_directory_map = {                                      
        ["/opt/jupengfei"] = "/home/ubuntu/compile",
}		

server_cfg = {                          
    ["remote_cmd_map"]      = remote_cmd_map,                         
    ["file_type_map"]       = file_type_map,                         
    ["share_directory_map"] = share_directory_map,                         
}                         

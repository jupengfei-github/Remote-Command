-- custom remote command                          
local remote_cmd_map = {                         
    explore  = "pcmanfm 2>/dev/null",                       
    file     = "emacs",                         
    search   = "krunner",                         
    compare  = "vimdiff",                         
    subl     = "subl",
}

-- command for specified file                         
local file_type_map = {                         
    ["txt:html:xml"] = remote_cmd_map.file,                         
}

-- shared directory. Don't edit this. Auto generated                         
local share_directory_map = {                                      
        ["/opt/jupengfei"] = "~/compile",
}		

server_cfg = {                          
    ["remote_cmd_map"]      = remote_cmd_map,                         
    ["file_type_map"]       = file_type_map,                         
    ["share_directory_map"] = share_directory_map,                         
}                         

-- custom remote command                          
local remote_cmd_map = {                          
    explore  = "explorer",                          
    file     = "\"C:\\Program Files (x86)\\Notepad++\\notepad++.exe\"",                          
    search   = "\"C:\\Program Files\\Everything\\Everything.exe\"",                          
    compare  = "\"C:\\Program Files (x86)\\Beyond Compare 4\\BCompare.exe\"",                          
}

-- command for specified file                          
local file_type_map = {                          
    ["txt:html:xml"] = remote_cmd_map.file,                          
}

-- shared directory. Don't edit this. Auto generated                          
local share_directory_map = {                                       
    ["/opt/jupengfei"] = "z:",
}

server_cfg = {                          
    ["remote_cmd_map"]      = remote_cmd_map,                          
    ["file_type_map"]       = file_type_map,                          
    ["share_directory_map"] = share_directory_map,                          
}                          

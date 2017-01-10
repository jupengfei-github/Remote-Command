server_cfg = {
    command_map = {
        default  = "explorer",
        notepad  = "\"C:\\Program Files (x86)\\Notepad++\\notepad++.exe\"",
        search   = "\"C:\\Program Files\\Everything\\Everything.exe\"",
        compare  = "\"C:\\Program Files (x86)\\Beyond Compare 4\\BCompare.exe\"",
    },

    file_type_map = {
        ["txt:html:xml"] = {
            command_map.notepad,
        },
    },
}

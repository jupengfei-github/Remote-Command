server_cfg = {
    -- custom remote command
    remote_cmd_map = {
        default  = "explorer",
        notepad  = "\"C:\\Program Files (x86)\\Notepad++\\notepad++.exe\"",
        search   = "\"C:\\Program Files\\Everything\\Everything.exe\"",
        compare  = "\"C:\\Program Files (x86)\\Beyond Compare 4\\BCompare.exe\"",
    },

    -- command for specified file
    file_type_map = {
        ["txt:html:xml"] = {
            command_map.notepad,
        },
    },

    -- shared directory. Don't edit this. Auto generated
    share_directory_map = {
        ["ju"] = "joqiwefjo",
    },
}

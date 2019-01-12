/*
 * Copyright (C) 2018-2024 The Remote-Command Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <sys/stat.h>
#include "vlog.c"

/**
 * param : string
 * return: int
 */
static int file_type (lua_State *lua_state) {
    struct stat pstat;

    const char* path = luaL_checkstring(lua_state, -1);
    if (path == NULL || stat(path, &pstat)) {
        vlog("get file[%s] stat error %d : %s", path == NULL? "" : path, errno, strerror(errno));
        lua_pushinteger(lua_state, -1);  // err
        goto error;
    }

    if (pstat.st_mode & S_IFDIR)         // dir
        lua_pushinteger(lua_state, 1);
    else if(pstat.st_mode & S_IFREG)     // reg
        lua_pushinteger(lua_state, 2);
    else if(pstat.st_mode & S_IFLNK)     // link
        lua_pushinteger(lua_state, 3);
    else
        lua_pushinteger(lua_state, 0);  // unknown

error:
    return 1;
}

/* register libutil module */
int luaopen_libutil (lua_State *lua_state) {
    struct luaL_Reg method[] = {
        {"file_type",  file_type},
        {NULL, NULL}
    };

    luaL_newlib(lua_state, method);
    return 1;
}

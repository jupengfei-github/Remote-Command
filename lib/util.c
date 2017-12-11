#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <sys/stat.h>

#define  LOG_TAG  ("libutil")
#include "vlog.c"

static int file_type (lua_State *lua_state) {
    struct stat pstat;
    const char  *path  = NULL;

    path = luaL_checkstring(lua_state, -1);

    if (path == NULL || stat(path, &pstat)) {
        vlog("get file stat error %d : %s", errno, strerror(errno));
        lua_pushinteger(lua_state, -1);
        goto error;
    }

    if (pstat.st_mode & S_IFDIR)
        lua_pushinteger(lua_state, 1);
    else if(pstat.st_mode & S_IFREG)
        lua_pushinteger(lua_state, 2);
    else if(pstat.st_mode & S_IFLNK)
        lua_pushinteger(lua_state, 3);
    else
        lua_pushinteger(lua_state, -1);

error:
    return 1;
} 

int luaopen_libutil (lua_State *lua_state) {
    struct luaL_Reg method[] = {
        {"file_type",  file_type},
        {NULL, NULL}
    };

    luaL_newlib(lua_state, method);
    return 1;
}

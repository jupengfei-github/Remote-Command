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

static int is_dir (lua_State *lua_state) {
    struct stat pstat;
    const char  *path  = NULL;

    path = luaL_checkstring(lua_state, -1);

    if (path == NULL || stat(path, &pstat)) {
        vlog("is_dir found error %d : %s", errno, strerror(errno));
        lua_pushboolean(lua_state, 0);
        goto error;
    }
    else
        vlog("is_dir : %s", path);

    if (pstat.st_mode == S_IFDIR)
        lua_pushboolean(lua_state, 1);
    else
        lua_pushboolean(lua_state, 0);

error:

    return 1;
} 

int luaopen_libutil (lua_State *lua_state) {
    struct luaL_Reg method[] = {
        {"is_dir",  is_dir},
        {NULL, NULL}
    };

    luaL_newlib(lua_state, method);
    return 1;
}

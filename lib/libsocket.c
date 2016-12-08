#include <stdio.h>
#include <stdlib.h>

#include "log.c"
#include "socket.c"

int luaopen_libsocket (lua_State *lua) {
    struct luaL_Reg method[] = {
        {"server_socket", server_socket},
        {"client_socket", client_socket},
        {"close_socket",  close_socket},
        {"send_data",     send_data},
        {"recv_data",     recv_data},
        {"listen_connect",listen_connect},
        {"listen_socket", listen_socket},
        {"log",           lua_log_msg},
        {"close_log",     lua_close_log},
        {NULL, NULL}
    };

    luaL_newlib(lua, method);
    return 1;
}

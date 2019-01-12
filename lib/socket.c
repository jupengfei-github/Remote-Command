#ifndef _SOCKET_C_
#define _SOCKET_C_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>

#include <sys/poll.h>
#include <sys/fcntl.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "vlog.c"

#define  SERVER_SOCKET_LENGTH 6
#define  POLL_TIMEOUT         600
#define  READ_DATA_LIEN       1024

static int check_ip_address (const char *ip) {
    int ip_part = 0, ip_part_cnt = 1;
    int i;

    if (ip == NULL)
        return 0;

    for (i = 0; ip[i]; i++) {
        if (ip[i] != '.' && !isdigit(ip[i]))
            break;

        if (isdigit(ip[i])) {
            ip_part = ip_part * 10 + ip[i] - '0';
            continue;
        }

        if (ip_part >= 255 || ip_part <= 0)
            break;

        ip_part_cnt++;
        ip_part = 0;
    }

    if (ip_part_cnt != 4 || ip_part >= 255)
        return 0;

    return 1;
}

static int check_ip_port (const lua_Number port) {
    return port > 0 && port < 65535;
}

/**
 * param : string
 * param : lua_Number
 * return: int
 */
static int client_socket(lua_State *lua) {
    struct sockaddr_in addr;

    const char* remote_ip   = (char*)luaL_checkstring(lua, 1);
    lua_Number  remote_port = (unsigned long)luaL_checknumber(lua, 2);

    if (!check_ip_address(remote_ip) || !check_ip_port(remote_port)) {
        vlog("fatal argument ip[%s] port[%ld]", remote_ip == NULL? "NULL" : remote_ip, remote_ip);
        goto err;
    }

    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        vlog("create socket failed %d : %s", errno, strerror(errno));
        goto err;
    }

    bzero(&addr, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(remote_port);
    addr.sin_addr.s_addr = inet_addr(remote_ip);

    if (connect(sockfd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(sockfd);
        sockfd = -1;
        vlog("connect socket[%s] failed %d : %s", remote_ip, errno, strerror(errno));
        goto err;
    }

err:
    lua_pushinteger(lua, sockfd);
    return 1;
}

/**
 * param : string
 * param : lua_Number
 * return: int
 */
static int server_socket (lua_State *lua) {
    struct sockaddr_in addr;

    const char* ip   = (char*)luaL_checkstring(lua, 1);
    lua_Number  port = (unsigned int)luaL_checkinteger(lua, 2);

    if (!check_ip_address(ip) || !check_ip_port(port)) {
        vlog("illegal argument ip[%s] port[%d]", ip == NULL? "NULL" : ip, port);
        goto err;
    }

    int sock_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (sock_fd < 0) {
        vlog("create socket error %d : %s", errno, strerror(errno));
        goto err;
    }

    bzero(&addr, sizeof(addr));
    addr.sin_family      = AF_INET;
    addr.sin_addr.s_addr = inet_addr(ip);
    addr.sin_port        = htons(port);

    if (bind(sock_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        vlog("bind [%s:%d] unexpected error %d : %s", ip, port, errno, strerror(errno));
        goto err1;
    }

    if (listen(sock_fd, SERVER_SOCKET_LENGTH) < 0) {
        vlog("listen [%s:%d] unexpected error %d : %s", ip, port, errno, strerror(errno));
        goto err1;
    }

    lua_pushinteger(lua, sock_fd);
    return 1;

err1:
    close(sock_fd); 
err:
    lua_pushinteger(lua, -1);
    return 1;
}

static int write_data (int sockfd, const char *line) {
    int write_len  = 0, total_len = 0;
    int remain_len = 0;
    int error = 0;

    if (sockfd < 0 || line == NULL) {
        vlog("invalid parameters in write_data");
        goto err;
    }

    remain_len = strlen(line);
    while (1) {
        write_len = write(sockfd, line, remain_len);

        if (write_len <= 0 && errno == EINTR)    
            continue;
        else if(write_len < 0) {
            vlog("[write_data] failed %d : %s", errno, strerror(errno));
            goto err;
        }
        else if(write_len == 0) {
            vlog("[write_data] remote socket may close %d : %s", errno, strerror(errno));
            goto err;
        }

        if (write_len == remain_len)
            break;

        remain_len -= write_len;
    }

    return 1;

err:
    return 0;
}

/**
 * param : lua_Integer
 * param : table
 * return: int
 */
static int send_data (lua_State *lua) {
    int len, i, j;
    int write_len = 0;
    const char *line;

    lua_Integer sockfd = luaL_checkinteger(lua, 1);
    if (sockfd < 0) {
        vlog("invalid file fd fd[%d]", sockfd);
        goto err;
    } 

    if (!lua_istable(lua, 2)) {
        vlog("illegal argument, second paramters must be a table ");
        goto err;
    }

    lua_pushnil(lua); /* first key */
    while (!lua_next(lua, 2)) {
        line = luaL_checkstring(lua, -1); 
        lua_pop(lua, 1);

        if (line != NULL && !write_data(sockfd, line))
            goto err;
    }

    lua_pushinteger(lua, 0);
    return 1;

err:
    lua_pushinteger(lua, -1);
    return 1;
}

/**
 * param : lua_Integer
 */
static int close_socket (lua_State *lua) {
    lua_Integer sockfd = luaL_checkinteger(lua, 1);
    if (sockfd >= 0)
        close(sockfd);

    return 0;
}

/**
 * param : lua_Integer
 * param : table
 * return: [int table]/[nil]
 */
static int recv_data  (lua_State *lua) {
    int  write_len = 0, ret = 0;
    char data[READ_DATA_LIEN] = {0};
    int index = 1;

    lua_Integer sockfd = luaL_checkinteger(lua, 1);
    if (sockfd < 0) {
        vlog("invalid socket fd [%d]", sockfd);
        goto err;
    }

    lua_newtable(lua);
    while (1) {
        ret = read(sockfd, data, READ_DATA_LIEN - 1);

        if (ret < 0 && (errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN))
            continue;
        else if (ret < 0) {
            vlog("receive data error %d : %s", errno, strerror(errno));
            goto err;
        }
        else if(ret == 0){
            vlog("[recv_data] error, remote socket may close %d : %s", errno, strerror(errno));
            goto err;
        }

        data[ret] = '\0';
        lua_pushstring(lua, data);
        lua_rawseti(lua, -2, index++);

        if (ret < READ_DATA_LIEN)
            break;

        write_len += ret;
    }

    lua_pushinteger(lua, write_len);
    return 2;

err:
    lua_pop(lua, 1);
    lua_pushnil(lua);
    return 1;
}

static int listen_connect (lua_State *lua) {
    struct pollfd fds[1];
    struct sockaddr_in addr;
    int sockfd, len, new_sockfd;

    sockfd = (int)luaL_checkinteger(lua, 1);
    if (sockfd < 0) {
        vlog("invalid socket fd [%d]", sockfd);
        goto err;
    }

    bzero(&addr, sizeof(addr));
    len = sizeof(addr);
    new_sockfd = accept(sockfd, (struct sockaddr*)&addr, &len);
    if (new_sockfd < 0) {
        vlog("accpet error found %d : %s", errno, strerror(errno));
        goto err;
    }

    lua_pushinteger(lua, new_sockfd);
    return 1;

err:
    lua_pushinteger(lua, -1);
    return 1;
}

/**
 * param : lua_Number
 * return: int
 */
static int listen_socket (lua_State *lua) {
    struct pollfd fds[1];
    int poll_ret;
    int len = 0;

    lua_Number sockfd = (int)luaL_checkinteger(lua, 1);
    if (sockfd < 0) {
        vlog("invalid socket fd [%d]", sockfd);
        return -1;
    }

    fds[0].fd = sockfd;
    fds[0].events = POLLIN;

    poll_ret = poll(fds, 1, POLL_TIMEOUT);
    if (poll_ret >= 0 && fds[0].revents & POLLIN)
        lua_pushinteger(lua, 0);
    else
        lua_pushinteger(lua, -1);

    return 1;
}

/* register libsocket module */
int luaopen_libsocket (lua_State *lua) {
    struct luaL_Reg method[] = {
        {"server_socket", server_socket},
        {"client_socket", client_socket},
        {"close_socket",  close_socket},
        {"send_data",     send_data},
        {"recv_data",     recv_data},
        {"listen_connect",listen_connect},
        {"listen_socket", listen_socket},
        {NULL, NULL}
    };

    luaL_newlib(lua, method);
    return 1;
}

#endif

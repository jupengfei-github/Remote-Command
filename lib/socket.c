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

#define  IP_LOCAL_HOST ("localhost")
#define  IP_LOCAL_LOOP ("127.0.0.1")
#define  SERVER_SOCKET_LENGTH 6
#define  POLL_TIMEOUT         600

int client_socket(lua_State *lua) {
    int sockfd;
    struct sockaddr_in addr;
    const char *remote_ip;
    unsigned int  remote_port;

    remote_ip   = (char*)luaL_checkstring(lua, 1);
    remote_port = (unsigned int)luaL_checkinteger(lua, 2);

    if (remote_ip == NULL || remote_port < 0 || remote_port > 65535) {
        log_msg("fatal argument ip[%s] port[%ld]", remote_ip == NULL? "NULL" : remote_ip, remote_ip);
        goto err;
    }

    log_msg("create client socket ip[%s] port[%d]", remote_ip, remote_port);
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        log_msg("create client socket failed %d : %s", errno, strerror(errno));
        goto err;
    }

    bzero(&addr, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(remote_port);
    addr.sin_addr.s_addr = inet_addr(remote_ip);

    if (connect(sockfd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        log_msg("connect remote socket failed %d : %s", errno, strerror(errno));
        goto err;
    }

    lua_pushinteger(lua, sockfd);
    return 1;

err:
    if (sockfd >= 0)
        close(sockfd);

    lua_pushinteger(lua, -1);
    return 1;
}

static int write_data (int sockfd, const char *line) {
    int write_len  = 0, total_len = 0;
    int remain_len = 0;
    int error = 0;

    if (sockfd < 0 || line == NULL) {
        log_msg("invalid parameters in write_data");
        goto err;
    }

    remain_len = strlen(line);
    while (1) {
        write_len = write(sockfd, line, remain_len);

        if (write_len < 0 && errno == EINTR)    
            continue;
        else if (write_len == 0) {
            log_msg("[write_data] remote socket may close");
            goto err;
        }
        else if (write_len < 0)
            goto err;

        if (write_len <= remain_len)
            break;

        remain_len -= write_len;
    }

    return 0;

err:
    return -1;
}

int send_data (lua_State *lua) {
    int  sockfd;
    int len, i, j;
    int write_len = 0;
    const char *line;

    sockfd = (int)luaL_checkinteger(lua, 1);
    if (sockfd < 0) {
        log_msg("invalid file fd fd[%d]", sockfd);
        goto err;
    } 

    if (!lua_istable(lua, 2)) {
        log_msg("illegal argument, second paramters must be a table ");
        goto err;
    }


    lua_pushnil(lua);
    while (lua_next(lua, 2) != 0) {
        line = luaL_checkstring(lua, -1); 
        lua_pop(lua, 1);

        if (line != NULL && write_data(sockfd, line) < 0)
            goto err;
    }


    lua_pushinteger(lua, 0);
    return 1;

err:
    lua_pushinteger(lua, -1);
    return 1;
}

int close_socket (lua_State *lua) {
    int sockfd;

    sockfd = luaL_checkinteger(lua, 1);
    if (sockfd >= 0)
        close(sockfd);

    return 0;
}

static int check_ip_address (char *ip) {
    int valid   = 1;
    int ip_part = 0, ip_part_cnt = 1;
    int i;

    if (ip == NULL) {
        log_msg("check ip null pointer");
        return -1;
    }

    if (!strcmp(IP_LOCAL_HOST, ip) || !strcmp(IP_LOCAL_LOOP, ip))
        return 0;

    for (i = 0; ip[i]; i++) {
        if (ip[i] != '.' && !isdigit(ip[i])) {
            valid = 0;
            break;
        }

        if (isdigit(ip[i])) {
            ip_part = ip_part * 10 + ip[i] - '0';
            continue;
        }

        if (ip_part >= 255 || ip_part <= 0) {
            valid = 0;
            break;
        }

        ip_part_cnt++;
        ip_part = 0;
    }

    if (!valid || ip_part_cnt != 4 || ip_part <= 0 || ip_part >= 255 || !isdigit(ip[i - 1])) {
        log_msg("check ip failed");
        return -1;
    }

    return 0;
}

int server_socket (lua_State *lua) {
    struct sockaddr_in addr;
    int    sock_fd;
    unsigned int    port;
    char   *ip;

    ip   = (char*)luaL_checkstring(lua, 1);
    port = (unsigned int)luaL_checkinteger(lua, 2);

    if (ip == NULL || check_ip_address(ip) || port <= 0 || port >= 65536) {
        log_msg("illegal argument ip[%s] port[%d]", ip == NULL? "NULL" : ip, port);
        goto err;
    }

    log_msg("create server socket ip[%s] port[%d]", ip, port);
    sock_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (sock_fd < 0) {
        log_msg("socket unexpected error %d : %s", errno, strerror(errno));
        goto err;
    }

    bzero(&addr, sizeof(addr));
    addr.sin_family      = AF_INET;
    addr.sin_addr.s_addr = inet_addr(ip);
    addr.sin_port        = htons(port);

    if (bind(sock_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        log_msg("bind unexpected error %d : %s", errno, strerror(errno));
        goto err1;
    }

    if (listen(sock_fd, SERVER_SOCKET_LENGTH) < 0) {
        log_msg("listen unexpected error %d : %s", errno, strerror(errno));
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

int recv_data  (lua_State *lua) {
    int  write_len = 0, ret, num = 0;
    char data[1024];
    char index[2] = {'1', '\0'};
    int sockfd;

    sockfd = luaL_checkinteger(lua, 1);
    if (sockfd < 0) {
        log_msg("invalid socket fd [%d]", sockfd);
        goto err;
    }

    lua_newtable(lua);
    while (1) {
        ret = read(sockfd, data, 1024);
        log_msg("read data %s : %d", data, ret);

        if (ret < 0 && (errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN))
            continue;
        else if (ret <= 0) {
            log_msg("receive data error %d : %s, remote socket may close", errno, strerror(errno));
            goto err;
        }

        index[1]++;
        lua_pushstring(lua, data);
        lua_setfield(lua, -2, index);

        write_len += ret;
        num++;

        if (ret < 1024)
            break;
    }

    close(sockfd);
    lua_pushinteger(lua, write_len);
    return 2;

err:
    lua_pushinteger(lua, -1);
    return 1;
}

int listen_connect (lua_State *lua) {
    struct pollfd fds[1];
    struct sockaddr_in addr;
    int sockfd, len, new_sockfd;

    sockfd = (int)luaL_checkinteger(lua, 1);
    if (sockfd < 0) {
        log_msg("invalid socket fd [%d]", sockfd);
        goto err;
    }

    bzero(&addr, sizeof(addr));
    new_sockfd = accept(sockfd, (struct sockaddr*)&addr, &len);
    if (new_sockfd < 0) {
        log_msg("accpet error found %d : %s", errno, strerror(errno));
        goto err;
    }

    lua_pushinteger(lua, new_sockfd);
    return 1;

err:
    lua_pushinteger(lua, -1);
    return 1;
}

int listen_socket (lua_State *lua) {
    struct pollfd fds[1];
    int poll_ret;
    int sockfd;
    int len = 0;

    sockfd = (int)luaL_checkinteger(lua, 1);
    if (sockfd < 0) {
        log_msg("invalid socket fd [%d]", sockfd);
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

#endif

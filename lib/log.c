#ifndef _LOG_C_
#define _LOG_C_

#include <syslog.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <errno.h>
#include <stdarg.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <sys/uio.h>
#include <sys/fcntl.h>

#define LOG_INDENT        ("remoteDesk")
#define LOG_INDENT_FILE   ("[remoteDesk] : ")
#define LOG_FILE_PATH     ("~/.remoteDesk.log")
#define LOG_FILE_LENGTH   120

#define min(a, b) ((a) > (b)? (b) : (a))
#define max(a, b) ((a) > (b)? (a) : (b))

static int log_open     =  0;
static int use_syslog   =  0;
static int log_file_fd  = -1;

static int syslog_exists () {
    char buf[100];
    char *p;
    FILE *file = NULL;

    file = popen("ps -e|grep syslog", "r");
    if (file == NULL)
        return -1;

    p = fgets(buf, 100, file);
    if (p == 0)
        return -1;

    p = strstr(buf, "syslog");
    pclose(file);

    if (p)
        return 0;
    else
        return -1;
}

char* translate_directory (char *path) {
    char *home = NULL, *new_path = NULL, *p = NULL;
    int  len = 0, cplen = 0;

    home = getenv("HOME");
    if (home == NULL || path == NULL)
        return NULL;

    new_path = (char*)malloc(LOG_FILE_LENGTH * sizeof(char)); 
    if(new_path == NULL) {
        printf("create new path malloc failed");
        return NULL;
    }

    p = strstr(path, "~");   
    if(p != NULL) {
        cplen = min(strlen(home), LOG_FILE_LENGTH - 1);
        memcpy(new_path, home, cplen); 
        len += cplen;

        cplen = min(strlen(p + 1), LOG_FILE_LENGTH - 1 - cplen);
        memcpy(new_path + strlen(home), p + 1, cplen);
        len += cplen; 

        new_path[len] = '\0';
    }
    else {
        cplen = min(strlen(path), LOG_FILE_LENGTH - 1);
        memcpy(new_path, path, cplen);
        new_path[cplen] = '\0';
    }

    return new_path;
}

static int init_log_file (char *path) {
    int  fd;
    char *dir_name, *home;
    int ret = 0;

    path = translate_directory(path);
    if (path == NULL)
        return -1;

    fd = access(path, F_OK);
    if (fd >= 0) {
        fd = access(path, W_OK);
        if (fd >= 0)
            goto new_file;
        else {
            printf("don't have permission to write log_file\n");
            ret = -1;
        }
    }
    else {
        dir_name = dirname(strdup(path));
        if (dir_name != NULL && access(dir_name, F_OK))
            mkdir(dir_name);
    }

new_file:
    log_file_fd = open(path, O_WRONLY | O_CREAT | O_APPEND,S_IRWXU | S_IRGRP | S_IROTH);
    if (log_file_fd < 0) {
        printf("open log_file failed %d : %s\n", errno, strerror(errno));
        ret = -1;
    }

    free(path);
    return ret;
}

static int open_log () {
    int ret = -1;

    if (!syslog_exists()) {
        openlog(LOG_INDENT, LOG_PID, LOG_USER);
        use_syslog = 1;
        ret = 0;
    }

    if (!use_syslog && !init_log_file(LOG_FILE_PATH)) {
        use_syslog = 0;
        ret = 0;
    }

    return ret;
}

static void log_file (char *str) {
    struct iovec iov[3];
    char enter[] = "\n";
    int len;

    if (str == NULL)
        return;

    iov[0].iov_base = LOG_INDENT_FILE;
    iov[0].iov_len  = strlen(LOG_INDENT_FILE);
    iov[1].iov_base = str;
    iov[1].iov_len  = strlen(str);
    iov[2].iov_base = enter;
    iov[2].iov_len  = strlen(enter);

    writev(log_file_fd, iov, sizeof(iov)/sizeof(struct iovec));
}

void log_msg (char *str, ...) {
    va_list vlist;
    char buf[1024];

    if (str == NULL)
        return;

    if (!log_open && open_log()) {
        printf("open log failed\n");
        return;
    }
    else
        log_open = 1;

    va_start(vlist, str);
    vsnprintf(buf, sizeof(buf), str, vlist);
    va_end(vlist);

    if (use_syslog)
        syslog(LOG_INFO, "%s\n", buf);
    else
        log_file(buf);
}

void close_log () {
    if (use_syslog)
        closelog();
    else if (log_file_fd >= 0)
        close(log_file_fd);
}

int lua_log_msg (lua_State *lua) {
    const char *msg = NULL;

    msg = luaL_checkstring(lua, 1);
    log_msg("%s", msg);

    return 0;
}

int lua_close_log (lua_State *lua) {
    close_log();
    return 0;
} 

#endif

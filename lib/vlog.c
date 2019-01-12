#ifndef _LOG_C_
#define _LOG_C_

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#include <libgen.h>
#include <errno.h>
#include <syslog.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <sys/uio.h>
#include <sys/fcntl.h>
#include <sys/time.h>

#define LOG_LEVEL         0
#define LOG_FILE_LENGTH   120

#ifndef LOG_TAG
#define LOG_TAG           ("rmd")
#endif

#define min(a, b) ((a) > (b)? (b) : (a))
#define max(a, b) ((a) > (b)? (a) : (b))

typedef enum _BOOL {
    TRUE, FALSE 
}BOOL;

/* use linux syslog */
static BOOL use_sys_log = TRUE;
static BOOL support_sys_log;
static int sys_log_fd;

/* use normal file */
static BOOL use_file_log = TRUE;
static int file_log_fd;

/* file log path */
static char FILE_LOG_PATH[] = {"~/.rmd.log"};

/* weather close log once log finished everytime */
static BOOL close_log_once = FALSE;

/* weather syslog running */
static BOOL syslog_exists () {
    char buf[100] = {0};

    FILE* file = popen("ps -e|grep syslog", "r");
    if (file == NULL)
        return FALSE;

    char* p = fgets(buf, 100 - 1, file);
    pclose(file);

    char* p = strstr(buf, "syslog");
    return p == NULL? FALSE : TRUE;
}

/* open syslog */
static int init_sys_log (void) {
    support_sys_log = syslog_exists();
    if (support_sys_log)
        openlog("", LOG_PID, LOG_USER);
}

static BOOL log_sys (char* tag, char* msg) {
    if (support_sys_log) {
        syslog(LOG_LEVEL, "[%s] %s\n", tag, msg);
        return TRUE;
    }
    else
        return FALSE;
}

/* you must need to free memory return by this function */
static char* translate_directory (const char *path) {
    char *home = NULL, *new_path = NULL;
    int  len = 0, cplen = 0;

    if (path == NULL)
        return NULL;

    new_path = (char*)malloc(LOG_FILE_LENGTH * sizeof(char)); 
    if(new_path == NULL) {
        printf("init_file_log failed. malloc new space failed");
        return NULL;
    }

    if(path[0] == '~') {
        if((home = getenv("HOME")) == NULL) {
            free(new_path);
            printf("init_file_log failed. can't found home direcotry");
            return NULL;
        }

        cplen = min(strlen(home), LOG_FILE_LENGTH - 1);
        memcpy(new_path, home, cplen); 
        len += cplen;

        cplen = min(strlen(path + 1), LOG_FILE_LENGTH - 1 - cplen);
        memcpy(new_path + strlen(home), path + 1, cplen);
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

/* open rmd.log file */
static int init_file_log (void) {
    char *path = NULL;

    if((path = translate_directory(FILE_LOG_PATH)) == NULL)
        return 0;

    file_log_fd = open(path, O_WRONLY | O_CREAT | O_APPEND,S_IRWXU | S_IRGRP | S_IROTH);
    free(path);

    if (file_log_fd < 0) {
        printf("open file_log [%s] failed %d : %s\n", path, errno, strerror(errno));
        return 0;
    }

    return 1;
}

static BOOL log_file (char *tag, char *str) {
    struct timeval t;
    struct iovec   iov[5];
    char spid[20], time[20];
    char enter[] = "\n";

    if (file_log_fd < 0)
        return FALSE;

    gettimeofday(&t, 0);
    sprintf(spid,  " %d %d ", (int)getpid(), (int)pthread_self());
    sprintf(time, " %ld ", t.tv_usec);

    if (tag == NULL) tag = "";
    if (str == NULL) str = "";

    iov[0].iov_base = time;
    iov[0].iov_len  = strlen(time);
    iov[1].iov_base = spid;
    iov[1].iov_len  = strlen(spid);
    iov[2].iov_base = tag;
    iov[2].iov_len  = strlen(tag);
    iov[3].iov_base = str;
    iov[3].iov_len  = strlen(str);
    iov[4].iov_base = enter;
    iov[4].iov_len  = strlen(enter);

    int ret = writev(file_log_fd, iov, sizeof(iov)/sizeof(struct iovec));
    if (ret < 0)
        printf("write msg[%s : %s] fail %d : %s\n", tag, str, path, errno, strerror(errno));

    return ret > 0? TRUE : FALSE;
}

static void log_local (char *tag, char *str) {
    struct timeval t;
    char spid[20], time[20];

    if (tag == NULL) tag = "";
    if (str == NULL) str = "";

    gettimeofday(&t, 0);
    sprintf(spid, " %d %d ", (int)getpid(), (int)pthread_self());
    sprintf(time, " %ld ", t.tv_usec);

    printf("%s %s %s %s\n", time, spid, tag, str);
}

static void init_log () {
    if (use_sys_log)
        init_sys_log();

    if (use_file_log)
        init_file_log();
}

void close_log () {
    if (use_sys_log == TRUE)
        closelog();

    if (use_file_log == TRUE && file_log_fd >= 0)
        close(file_log_fd);
}

static void log_msg (char *tag, char *msg) {
    BOOL handle = FALSE;

    init_log();
    
    if (use_sys_log)
        handle = log_sys(tag, msg);

    if (use_file_log)
        handle = log_file(tag, msg);

    close_log();

    if (!handle)
        log_local(tag, msg);
}

void vlog (char *str, ...) {
    va_list vlist;
    char buf[1024];

    if (str == NULL)
        return;
    
    va_start(vlist, str);
    vsnprintf(buf, sizeof(buf), str, vlist);
    va_end(vlist);

    log_msg (LOG_TAG, buf);
}

/**
 * param string
 * param string
 */
static int lua_log (lua_State *lua) {
    const char* tag = (char*)luaL_checkstring(lua, 1);
    const char* msg = (char*)luaL_checkstring(lua, 2);

    log_msg(tag, msg);
    return 0;
}

/* register liblog module */
int luaopen_liblog (lua_State *lua) {
    struct luaL_Reg method[] = {
        {"log",           lua_log},
        {NULL, NULL}
    };

    luaL_newlib(lua, method);
    return 1;
}

#endif

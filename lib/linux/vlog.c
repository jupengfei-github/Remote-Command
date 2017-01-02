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
#define LOG_TAG           ("Unknown")
#endif

#define min(a, b) ((a) > (b)? (b) : (a))
#define max(a, b) ((a) > (b)? (a) : (b))

typedef enum _BOOL {
    TRUE, FALSE 
}BOOL;

/* logsystem we use. we support syslog and file_log in linux
 * and only file_log in windows 
 */
static BOOL use_sys_log = TRUE, use_file_log =  FALSE;
static int sys_log_fd  = -1,    file_log_fd  = -1;

/* file log path */
static char FILE_LOG_PATH[100] = {"~/.cmd_gui.log"};

/* weather close log once log finished everytime */
static BOOL close_log_once = FALSE;

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

static int init_sys_log (void) {
    if (syslog_exists()) {
        sys_log_fd = -1;
        printf("init_sys_log failed. don't found syslog in current system");
    }
    else {
        openlog("", LOG_PID, LOG_USER);
        sys_log_fd = 0;
    }

    return sys_log_fd;
}

/* you may need to free memory return by this function */
static char* translate_directory (char *path) {
    char *home = NULL, *new_path = NULL, *p = NULL;
    int  len = 0, cplen = 0;

    new_path = (char*)malloc(LOG_FILE_LENGTH * sizeof(char)); 
    if(new_path == NULL) {
        printf("init_file_log failed. malloc new space failed");
        return NULL;
    }

    p = strstr(path, "~");   
    if(p != NULL) {
        if((home = getenv("HOME")) == NULL) {
            free(new_path);
            printf("init_file_log failed. can't found home direcotry");
            return NULL;
        }

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

static int init_file_log (void) {
    int  fd;
    char *dir_name, *home, *path;
    int ret = 0;

    if((path = translate_directory(FILE_LOG_PATH)) == NULL)
        return -1;

    fd = access(path, F_OK);
    if (fd >= 0) {
        fd = access(path, W_OK);
        if (fd >= 0)
            goto new_file;
        else {
            printf("need permission to write log_file, please select another file\n");
            ret = -1;
            goto error;
        }
    }
    else {
        dir_name = dirname(strdup(path));
        if (dir_name != NULL && access(dir_name, F_OK))
            mkdir(dir_name, S_IRWXU|S_IRGRP|S_IROTH);
        
       // free(dir_name);
    }

new_file:
    file_log_fd = open(path, O_WRONLY | O_CREAT | O_APPEND,S_IRWXU | S_IRGRP | S_IROTH);
    if (file_log_fd < 0) {
        printf("open file_log [%s] failed %d : %s\n", path, errno, strerror(errno));
        ret = -1;
    }

error:
    free(path);
    return ret;
}

static void file_log (char *tag, char *str) {
    struct timeval t;
    struct iovec   iov[5];
    pid_t pid;
    int   tid;

    char spid[20], time[20];
    char enter[] = "\n";
    int len;

    gettimeofday(&t, 0);
    pid = getpid();
    tid = pthread_self();

    sprintf(spid,  " %d %d ", pid, tid);
    sprintf(time, " %ld ", t.tv_usec);

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

    writev(file_log_fd, iov, sizeof(iov)/sizeof(struct iovec));
}

static void local_log (char *tag, char *str) {
    struct timeval t;
    char spid[20], time[20];

    gettimeofday(&t, 0);
    sprintf(spid, " %d %d ", (int)getpid(), (int)pthread_self());
    sprintf(time, " %ld ", t.tv_usec);

    printf("%s %s %s %s\n", time, spid, tag, str);    
}

static void log_msg (char *tag, char *msg) {
    BOOL handle = FALSE;

    if (msg == NULL || tag == NULL)
        return;
    
    if (use_sys_log == TRUE && (sys_log_fd >= 0 || !init_sys_log())) {
        syslog(LOG_LEVEL, "[%s] %s\n", tag, msg);
        handle = TRUE;
    }

    if (use_file_log == TRUE && (file_log_fd >= 0 || !init_file_log())) {
        file_log(tag, msg);
        handle = TRUE;
    }

    if (handle == FALSE)
        local_log(tag, msg);
}

void close_log () {
    if (use_sys_log == TRUE)
        closelog();

    if (use_file_log == TRUE && file_log_fd >= 0)
        close(file_log_fd);
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

    if (close_log_once == TRUE)
        close_log();
}

void set_sys_log (int b) {
    use_sys_log = (BOOL)b;   
}

void set_file_log (int b) {
    use_file_log = (BOOL)b;
}

void set_close_once (int b) {
    close_log_once = (BOOL)b;
}

static int lua_log (lua_State *lua) {
    char *msg = NULL;
    char *tag = NULL;

    tag = (char*)luaL_checkstring(lua, 1);
    msg = (char*)luaL_checkstring(lua, 2);

    set_close_once(1);
    log_msg(tag, msg);

    return 0;
}

int luaopen_liblog (lua_State *lua) {
    struct luaL_Reg method[] = {
        {"log",           lua_log},
        {NULL, NULL}
    };

    luaL_newlib(lua, method);
    return 1;
}

#endif

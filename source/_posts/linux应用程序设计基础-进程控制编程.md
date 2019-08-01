---
title: linux应用程序设计基础--进程控制编程
tags:
  - Linux
date: 2012-11-20 09:44
categories:
  - Linux
---

# 获取ID
```c
#include <sys/type.h>
#include <unistd.h>

pid_t getpid(void);
pid_t getppid(void);
```

# 创建进程
```c
#include <unistd.h>

pid _t fork(void);//代码共享，数据拷贝，父进程与子进程运行顺序不确定
pid_t vfork(void);//代码数据共享，子进程先执行，父进程后执行
```

<!-- more -->

# exec函数族
exec启动一个新进程代替原有进程（替换代码）包括数据，因此PID不变
```c
#include <unistd.h>

int execl(const char *path,const char *arg1,...)//path:被执行程序名（包含路径），eg：execl了("/bin/ls","ls","-al","/etc/passwd",(char*)0);

int execlp(const char *path,const char *arg1,...)//path不包含路径，从path环境变量里面查找

int execv(const char *path,char *const argv[])

int system(const char *string)//产生子进程执行string命令
```

# 进程等待
```c
#include <sys/type.h>
#include <sys/wait.h>

pid_t wait(int *status);//阻塞进程，知道某个子进程退出，返回等待进程号
```



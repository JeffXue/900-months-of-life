---
title: linux应用程序设计基础--多线程程序设计
tags:
  - Linux
date: 2012-11-21 14:22
categories:
  - Linux
---

# 为什么使用多线程原因
- 线程比进程节俭，轻量级
- 运行一个进程的多个线程，他们使用相同的地址空间，线程间切换更快
- 使CPU更有效
- 改善程序结构

# 多线程遵循POSIX线程接口
pthread（#include <pthread.h>）
    - 连接时需要libpthread.a库

<!-- more -->

# 创建线程
```c
int pthread_create(pthread_t *tidp,const pthread_attr_t *attr,void *(*start_rtn)(void),void *arg);
```

    - tidp ---- 线程id
    - attr ---- 属性
    - start_rtn ---- 线程要执行的函数
    - arg ---- 参数

# 终止线程exit/_exit
```c
void pthread_exit(void * rval_ptr);
```

    - 从启动例程中返回
    - 其他进程终止
    - 线程自己调用pthread_exit

# 线程等待
```c
int pthread_join(pthread_t tid,void **rval_ptr);
```
阻塞调用进程，rval_ptr ---- 线程退出时的返回值的指针

# 线程标识
```c
//返回线程id
pthread_t pthread_self(void);
```

# 线程清除
- 正常：pthread_exit/return
- 不正常：其他干预/出错（存在资源释放问题）
```c
//pthread_cleanup_push到pthread_cleanup_pop 来解决资源释放（包括exit 异常 不包括return）
void pthread_cleanup_push(void(*rtn)(void *),void *arg);//将清楚函数压入清除栈
void pthread_cleanup_pop(int execute);//将清除函数弹出清除栈
```

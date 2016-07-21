---
title: linux应用程序设计基础--系统调用访问文件
tags:
  - Linux
date: 2012-11-19 18:44
categories:
  - Linux Programming
---

# 文件编程
- 系统调用（本文针对该类型）
- C语言调用

# 创建文件
```c
int creat (const char *filename,mode_t mode)
```
filename：文件名，默认在当前目录
mode：创建模块权限
eg：
```c
creat(filenam，0755)
```

<!-- more -->

# 打开文件
```c
int open(const char *filename，int flags)
int open(const char *filename，int flags，mode_t mode)
```
返回值为fd，文件描述符
flags：打开标志，当flags=O_CREATE时使用3个参数
eg：
```c
fd=open(argv[1],O_CREATE|O_RDWR,0755)
```

# 关闭文件
```c
int close(int fd)
```
fd为文件描述符

# 读文件
```c
int read(int fd,const void *buf,size_t length);
//从fd读取length字节数据到buf缓冲区，返回实际读取的字节数
```

# 写文件
```c
int write(int fd,const void * buf,size_t length);
//将缓冲区buf中的length个字节写入到fd
```

# 文件定位
```c
int lseek(int fd,offset_t offset,int whence);
//将文件指针相对whence移动offset，返回相对文件头位置
```
offset：字节，可为负
whence：当前/头/尾

# 访问判断
```c
int access (const char *pathname,int mode)
```

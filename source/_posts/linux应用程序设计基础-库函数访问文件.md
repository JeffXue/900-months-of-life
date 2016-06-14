---
title: linux应用程序设计基础--库函数访问文件
tags:
  - linux
date: 2012-11-19 19:01
categories:
  - linux programming
---

C库函数独立于具体的操作系统，具有较强移植性

# 创建和打开
```c
FILE *fopen(const char *filename,const char *mode);//linux 不区分二进制和文件,因此mode的b标志基本没有影响
eg: FILE *fd;
fd=fopen("c1.txt","rt");
```

# 读文件 
```c
size_t fread(void *ptr,size_t size,size_t n,FILE *stream);
```

<!-- more -->

# 写文件 
```c
size_t fwrite(const void *ptr,size_t size,size_t n,FILE *stream);
```

# 读写一个字符
```c
int fgetc(FILE *stream);
int fput(int c,FILE *stream);
```

# 格式化读写
```c
fscanf(FILE *stream,char *format[,argument...]);//fscanf(stdin,"%d",&i)
fprintf(FILE *stream,char *format,argument);//fprintf(stream,"%s,%c",s,c)
```

# 定位 
```c
int fseek(FILE *stream,long offset,int whence);
```

# 获得路径
```c
#include <unistd,h>
char *getcwd(char *buffer,size_t size);
```

# 创建目录
```c
#include <sys/stat.h>
int mkdir (char *dir,int mode);
```

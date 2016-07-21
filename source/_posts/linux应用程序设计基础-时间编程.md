---
title: linux应用程序设计基础--时间编程
tags:
  - Linux
date: 2012-11-19 19:14
categories:
  - Linux Programming
---

# 时间类型
UTC ---- 世界标准时间：格林威治时间GMT
日历时间 ---- 从1970-1-1到现在的秒数

# 获得日历时间
```c
#include <time.h>
time_t time(time_t *tloc);
```

<!-- more -->

# 时间转换
转化为GMT：
```c
struct tm *gmtime(const time_t *timep);
```
转化为本地时间：
```c
struct tm *localtime(const time_t *timep);//注意tm结构
```

# 时间显示
TM结构转化为字符串：
```c
char *asctime(const struct tm *tm);
```
日历时间转化为字符串：
```c
char *ctme(const time_t *timep);
```

# 从凌晨到现在的时间差：
```c
int gettimeofday(struct timeval *tv,struct timezone *tz);
```

# 延时函数：
```c
unsigned int sleep(second);//秒数
void usleep(mirosecond);//微妙
```

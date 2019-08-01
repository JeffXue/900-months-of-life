---
title: linux应用程序设计基础--Makefile工程管理
tags:
  - Linux
  - makefile
date: 2012-11-19 17:58
categories:
  - Linux
---

- GNU make 构建和管理软件工具

- Makefile 描述工程编译，链接等规则
.PHONY 将clean声明为伪目标
```makfile
hello : main.o func.o
    gcc main.o func.o -o hello
main.o : main.c
    gcc main.c -o main.o
func.o : func.c
    gcc func.c -o func.o
.PHONY : clean
clean:
    rm -rf .o*
```

<!-- more -->

- makefile 只有一个目标文件 (make  -f  文件名 指定makefile文件）

- makefile 将没有任何依赖只有执行动作的目标成为伪目标

- 变量：
```
obj = main.o func.o
hello: $(obj)
gcc $(obj) -o hello
```

- 使用#注释  TAB键缩进

- 系统默认自动化变量

`$n` ---- 所有依赖
`$@` ---- 目标
`$<` ---- 第一个依赖
例子：
```
hello  : hello.o func.o
@gcc $n -o $@ #（gcc前面的@用于取消回显）
```


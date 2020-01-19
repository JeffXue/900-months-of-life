---
title: linux应用程序设计基础--GDB调试
tags:
  - Linux
  - gdb
date: 2012-11-19 17:46
categories:
  - 嵌入式
---

# GDB作用
（1）启动被调试程序
（2）让程序在指定位置停止
（3）可检查程序状态（如变量值）

# 启动GDB
gdb test

<!-- more -->

# GDB命令：
- list（l） 查看程序
- break（b）打断点+行号/函数名/条件断点（b main / b 23 / b test.c 23 / b 5 if i = 10）
- info break 查看断点
- delete 1 删除第一个断点
- run（r） 运行程序
- next（n） 下一步（不进入函数内部）
- step（s）单步（进入子函数内部）
- continue（c） 继续运行
- print（P）查看变量P
- finish 运行至函数结束
- watch 监控变量
- quit（q） 退出gdb


---
title: ARM-Tiny6410-开发环境搭建-Hardware_Linux_arm-linux-gcc
tags:
  - ARM
  - Tiny6410
date: 2012-12-22 16:35
categories: 嵌入式
---

# 准备硬件设备

1. tiny6410开发板
2. USB转串口线（若有串口接口则不必）
3. 交叉网线
4. 交换器
5. PC机（windows7系统）
6. 普通网线

# 搭建调试环境

1. 根据Tiny6410 刷机手册安装linux 系统到开发板，开发板开机则可测试，可根据linux开发手册进行测试；
2. 下载putty 软件作为终端（windows7 没有超级终端）
    - putty 选择Serial 设置串口号和波特率115200
    - 在connection进行高级设置如下：（Flow Control 需要选择为none）
3. 串口线连接到开发板和PC机上（提示安装驱动则上网下载USB转串口驱动进行安装）
    - 安装完成后使用putty 连接到到开发板
    - 可自行根据linux 开发手册进行串口控制开发板测试
4. 安装VMware 虚拟机
5. 安装redhat 5 （镜像文件在光盘中可找到）
6. 设置redhat网络
    - redhat 网络连接方式为桥接（ 在VM –setting 可进入）
    - 以root登陆redhat 后设置IP获取方式为manual（*注设置的静态IP要与开发板上IP为同一网段）
7. 设置windows上网络
    - 进入到更改适配器设置，右击本地连接进入属性，设置IPV4属性为静态IP（*注设置的静态IP要与开发板上IP为同一网段）
8. 网线连接
    - PC机上采用普通网线，连接到交换机上
    - 开发板采用交叉网线，连接到交换机上
    - Redhat，windows 和开发板可以通过终端互ping成功，则网络配置成功
9. 设置文件共享 
    - 文件共享的方式有很多：samba NFS TFTP
    - 而我推荐使用最简单的方式使用VMware 自带的一个文件共享功能
    - 首先，开启redhat 后单击VM下的install-VMtools，安装后则可使用共享文件功能
    - 在VM-setting 中设置需要共享的文件夹
    - 设置好后可以在mnt 下找到共享的目录

# 交叉编译环境
可参考友善linux开发手册上内容

---
title: memcached1.4.25编译安装
tags:
  - memcached
date: 2016-04-19 10:40:58
categories: 运维
---

# 概述
Memcached 是一个高性能的分布式内存对象缓存系统，用于动态Web应用以减轻数据库负载。它通过在内存中缓存数据和对象来减少读取数据库的次数，从而提高动态、数据库驱动网站的速度。Memcached基于一个存储键/值对的hashmap。其守护进程（daemon ）是用C写的，但是客户端可以用任何语言来编写，并通过memcached协议与守护进程通信。

# 安装
可见[github脚本](https://raw.githubusercontent.com/JeffXue/common_scripts/master/install_memcached1.4.25.sh)

## libevent
memcached是基于libevent的事件处理,libevent是一个事件触发的网络库，适用于windows、linux、bsd等多种平台，内部使用select、epoll、kqueue等系统调用管理事件机制
```
tar xvzf libevent-2.0.22-stable.tar.gz -C /usr/local
cd /usr/local/libevent-2.0.22-stable
./configure --prefix=/usr/local/libevent2022
make && make install
```

## memcached
```
tar xvf memcached-1.4.25.tar.gz -C /usr/local/
cd /usr/local/memcached-1.4.25
./configure --prefix=/usr/local/memcached --enable-sasl --with-libevent=/usr/local/libevent2022
make && make install
```

## sasl
若需要使用sasl进行认证，需要安装sasl
```
apt-get install libsasl2-2 sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules -y
```

配置/etc/default/saslauthd
```
# 配置为开机默认启动
START=yes

#采用的密码验证机制为shadow，即直接使用系统的账号密码
MECHANISMS="shadow"
```

启动sasl
```
/etc/init.d/saslauthd start
```

# 基本操作

## 启动
```
/usr/local/memcached/bin/memcached -p 11211 -l 127.0.0.1 -d  -u root -m 10 -c 256 -P /tmp/memcached.pid
```

启动参数说明：

参数 | 说明
- | -
-p <num> | 是设置Memcache监听的端口（默认11211）
-l <addr> | 监听的服务器IP地址（默认0.0.0.0）
-d | 启动一个守护进程
-u <username> | 运行Memcache的用户（当要以root用户运行时需指定）
-m <num> | 分配给Memcache使用的内存数量，单位是MB
-M | 当内存溢出时返回错误（而不是移除items）
-c <num> | 最大运行的并发连接数（默认为1024）
-P <file> | 设置保存Memcache的pid文件
-t <num> | 所使用的线程数量（默认为4）
-R | 每个事件的最大请求数（默认为20）（Maximum number of requests per event, limits the number of requests process for a given connection to prevent starvation）
-S | 启动sasl认证
-F | 禁用flush_all命令

## 停止
直接杀掉进程即可
```
kill `cat /tmp/memcached.pid`
```

## 查看状态
```
telnet 127.0.0.1 11211
stats
```

## 清空统计数据
```
telnet 127.0.0.1 11211
stats reset
```

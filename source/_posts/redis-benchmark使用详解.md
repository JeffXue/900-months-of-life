---
title: redis-benchmark使用详解
tags:
  - redis
date: 2016-04-15 23:05:59
categories: 中间件
---

# redis-benchmark

redis-benchmark是redis自带的一个工具，可用于测试redis的性能

# 参数说明
```bash
Usage: redis-benchmark [-h <host>] [-p <port>] [-c <clients>] [-n <requests]> [-k <boolean>]

 -h <hostname>      Server hostname (default 127.0.0.1) #所要连接的机器
 -p <port>          Server port (default 6379) #服务端口
 -s <socket>        Server socket (overrides host and port)
 -a <password>      Password for Redis Auth #认证密码
 -c <clients>       Number of parallel connections (default 50) #并发连接数
 -n <requests>      Total number of requests (default 10000) #总的请求数量
 -d <size>          Data size of SET/GET value in bytes (default 2) #SET和GET value的大小
 -dbnum <db>        SELECT the specified db number (default 0) #选择db number
 -k <boolean>       1=keep alive 0=reconnect (default 1) # 设置是否开启keepalive
 -r <keyspacelen>   Use random keys for SET/GET/INCR, random values for SADD
  Using this option the benchmark will expand the string __rand_int__
  inside an argument with a 12 digits number in the specified range
  from 0 to keyspacelen-1. The substitution changes every time a command
  is executed. Default tests use this to hit random keys in the
  specified range.
 -P <numreq>        Pipeline <numreq> requests. Default 1 (no pipeline).
 -q                 Quiet. Just show query/sec values # 静态模式运行
 --csv              Output in CSV format # 输出csv
 -l                 Loop. Run the tests forever #一直运行
 -t <tests>         Only run the comma separated list of tests. The test
                    names are the same as the ones produced as output. # 设置测试项
 -I                 Idle mode. Just open N idle connections and wait. # 空闲模式，只创建连接
```

<!-- more -->

# 范例
```bash
#默认情况下是每种类型发送10000个请求，并发50个连接，3bytes的payload，开启keepalive
#具体会进行以下类型测试：
#    PING_INLINE
#    PING_BULK
#    SET
#    GET
#    INCR
#    LPUSH
#    LPOP
#    SADD
#    SPOP
#    LPUSH
#    LRANGE_100
#    LRANGE_300
#    LRANGE_500
#    LRANGE_600
#    MSET
./redis-benchmark

# 并发20，发送10W个请求
./redis-benchmark  -n 100000 -c 20

# 测试SET，使用100000000个键
./redis-benchmark -t set -n 1000000 -r 100000000

# 测试多个命令，并输出csv格式数据
./redis-benchmark -t ping,set,get -n 100000 --csv

```

---
title: redis2.8编译安装
tags:
  - redis
date: 2016-04-15 23:04:32
categories: 中间件
---

# 概述
Redis is an open source (BSD licensed), in-memory data structure store, used as database, cache and message broker. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs and geospatial indexes with radius queries. Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.
You can run atomic operations on these types, like appending to a string; incrementing the value in a hash; pushing an element to a list; computing set intersection, union and difference; or getting the member with highest ranking in a sorted set.
In order to achieve its outstanding performance, Redis works with an in-memory dataset. Depending on your use case, you can persist it either by dumping the dataset to disk every once in a while, or by appending each command to a log. Persistence can be optionally disabled, if you just need a feature-rich, networked, in-memory cache.
Redis also supports trivial-to-setup master-slave asynchronous replication, with very fast non-blocking first synchronization, auto-reconnection with partial resynchronization on net split.

# 安装
具体可见[安装脚本](https://raw.githubusercontent.com/JeffXue/common_scripts/master/install_redis2.8.sh)
```bash
tar xvzf redis-2.8.24.tar.gz -C /usr/local/
cd /usr/local/redis-2.8.24
make

mkdir /usr/local/redis
cp redis.conf sentinel.conf /usr/local/redis
cd src
cp redis-benchmark redis-server redis-cli redis-sentinel /usr/local/redis
```

<!-- more -->

# 基本操作
## 启动
```bash
cd /usr/local/redis
./redis-server ./redis.conf
```

## 停止
```bash
cd /usr/local/redis
# 若redis配置了密码使用-a passwd 指定密码 即可
./redis-cli -p 6379 shutdown

```

## 查看性能数据
```bash
# 实时监控redis的操作
./redis-cli -h 127.0.0.1 -p 6379 monitor


# 查看redis的统计信息
./redis-cli -h 127.0.0.1 -p 6379 info
```

## 清空数据
```bash
./redis-cli -h 127.0.0.1 -p 6379 flushall
```


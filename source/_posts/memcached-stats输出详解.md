---
title: memcached stats输出详解
tags:
  - memcached
date: 2016-04-19 10:43:26
categories: 中间件
---

STAT | 说明
- | -
STAT pid 26227    | 进程号
STAT uptime 48196 | 启动运行时长
STAT time 1461032409 | 当前系统时间
STAT version 1.4.25 | memcached版本号
STAT libevent 2.0.19-stable | libevent版本号
STAT pointer_size 64 | 操作系统指针大小
STAT rusage_user 1.136071  | 
STAT rusage_system 0.528033 |
**STAT curr_connections 10** | **当前打开的连接数**
STAT total_connections 16 | 打开过的总的连接数
STAT connection_structures 11 | 分配的连接结构的数量
STAT reserved_fds 20 | 
STAT cmd_get 24 | get总请求数量
STAT cmd_set 8 | set总请求数量
STAT cmd_flush 0 | flush总请求数量
STAT cmd_touch 0 | touch总请求数量
**STAT get_hits 16** | **get命中的请求数量**
**STAT get_misses 8** | **get不命中的请求数量**
STAT delete_misses 0 | delete不命中的请求数量
STAT delete_hits 0 | delete命中的请求数量
STAT incr_misses 0 | incr不命中的请求数量
STAT incr_hits 0 | incr命中的请求数量
STAT decr_misses 0 |decr不命中的请求数量
STAT decr_hits 0 | decr命中的请求数量
STAT cas_misses 0 | cas不命中的请求数量
STAT cas_hits 0 | cas命中的请求数量
STAT cas_badval 0 | 
STAT touch_hits 0 | touch命中请求数量
STAT touch_misses 0 | touch不命中请求数量 
STAT auth_cmds 0 | auth数量
STAT auth_errors 0 | auth错误数量
STAT bytes_read 2447 | 读取字节数
STAT bytes_written 4957 | 写入字节数
**STAT limit_maxbytes 1073741824** | **最大内存大小**
STAT accepting_conns 1 | 
STAT listen_disabled_num 0 | 
STAT time_in_listen_disabled_us 0 | 
**STAT threads 4** | **线程数量**
STAT conn_yields 0 | 
STAT hash_power_level 16 | 
STAT hash_bytes 524288 | 
STAT hash_is_expanding 0 |
STAT malloc_fails 0 | 
STAT bytes 1762 | 
**STAT curr_items 8** | **当前缓存对象数量**
STAT total_items 8 | 总的缓存对象数量（包括删除掉的）
STAT expired_unfetched 0 | 
STAT evicted_unfetched 0 |
**STAT evictions 0** | **为了获取空闲内存删除的items数量，比如超过缓存大小时根据LRU算法移除的对象，以及过期的对象**
STAT reclaimed 0 | 已经过期的items数量
STAT crawler_reclaimed 0 | 
STAT crawler_items_checked 0 | 
STAT lrutail_reflocked 0 | 
END | 

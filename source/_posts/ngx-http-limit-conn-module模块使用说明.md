---
title: ngx_http_limit_conn_module模块使用说明
categories: 运维
tags:
  - Nginx
date: 2016-03-22 18:18:21
---


ngx_http_limit_conn_module限制指定key值的并发连接数，如限制单个IP的连接数。

并不是所有连接都会统计，只有当这个请求正在被处理，并且整个请求头已经被读取的情况下，这个连接才会被统计进来。

例子：
```bash
http {
    # Sets parameters for a shared memory zone that will keep states for various keys. 
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    # 设置超过最大连接数后的返回码，默认为503
    limit_conn_status 503;

    ...

    server {

        ...

        location /download/ {
            # Sets the shared memory zone and the maximum allowed number of connections for a given key value
            limit_conn addr 1;
        }
```

<!-- more -->

可以设置多个限制：
```bash
    limit_conn_zone $binary_remote_addr zone=perip:10m;
    limit_conn_zone $server_name zone=perserver:10m;

    server {
        ...
        limit_conn perip 10;
        limit_conn perserver 100;
    }
```

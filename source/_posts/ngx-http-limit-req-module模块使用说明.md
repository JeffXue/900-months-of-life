---
title: ngx_http_limit_req_module模块使用说明
categories: 运维
tags:
  - Nginx
date: 2016-03-22 20:39:40
---


ngx_http_limit_req_module用于限制指定key的并发请求数。例如可以限制单个IP地址的请求速率。限制是使用漏桶算法的方法来实现。

例子：
```
http {
    ＃ Sets parameters for a shared memory zone that will keep states for various keys
    limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
    # 设置拒绝请求返回的请求码
    limit_req_status 503;
    ...

    server {

        ...

        location /search/ {
            # sets the shared memory zone and the maximum burst size of requests
            limit_req zone=one burst=5;
        }
```

# limit_req指令

>Syntax:    limit_req zone=name [burst=number] [nodelay];
>Default:   —
>Context:   http, server, location

当请求速度超过了zone所配置的速度，他们的请求会被延时，就像以所设定的速度在进行请求一样。超出限制的请求数量超过了最大的burst大小，会直接返回503，默认情况下最大的burst为0.

如果不希望超出的请求被延时处理，可以设置nodelay：
```
    limit_req zone=one burst=5 nodelay;
```

可以设置多个limit_req指令
```
    limit_req_zone $binary_remote_addr zone=perip:10m rate=1r/s;
    limit_req_zone $server_name zone=perserver:10m rate=10r/s;

    server {
        ...
        limit_req zone=perip burst=5 nodelay;
        limit_req zone=perserver burst=10;
}
```


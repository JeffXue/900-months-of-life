---
title: ngx_http_headers_module模块使用说明
categories: 运维
tags:
  - Nginx
date: 2016-03-22 17:59:04
---



ngx_http_headers_module 允许添加Expires和Cache-Control域和任意的域到响应头中。

例子
```
expires    24h;
expires    modified +24h;
expires    @24h;
expires    0;
expires    -1;
expires    epoch;
expires    $expires;
add_header Cache-Control private;
```


# add_header指令

>Syntax:    add_header name value [always];
>Default:   —
>Context:   http, server, location, if in location

当请求响应码为200,201,204,206,301,302,303,304或307时，该配置的域将会添加到应答头中，可以有多个add_header指令。这些指令均会继承上一层的，除非当前没有使用add_header

# expires指令

>Syntax:    expires [modified] time;
                expires epoch | max | off;
>Default:   expires off;
>Context:   http, server, location, if in location

该指令为在应答头中添加了Expires和Cache-Control域。
后面为负数，将添加头：Cache-Control: no-cache
后面为正数/0，将添加头：Cache-Control: max-age=t

可以根据不同文件类型设置不同的超时时间
```
    map $sent_http_content_type  $expires {
        "~*image/*"                         7d;
        "~*application/x-javascript"        7d;
        "~*text/css"                        7d;
        "~*text/javascript"                 7d;
        "~*application/javascript"          7d;
        "~*text/plain"                      1d;
        "~*application/x-shockwave-flash"   7d;
        "~*video/x-flv"                     7d;
        "~*application/pdf"                 7d;
        default                             off;
    }

    expires $expires;
```
